# Example

class FakeRecord  # quick'n'dirty ActiveRecord
  attr_accessor :attributes

  def initialize(attributes = {})
    @attributes = attributes
  end

  def method_missing(method, *args, &block)
    if respond_to? method
      @attributes[method]
    else
      super
    end
  end

  def respond_to?(method)
    @attributes.has_key?(method) || super
  end
end


### Models:

class User < FakeRecord
  def admin?
    first_name == 'Martin'
  end

  attr_accessor :account, :albums
end

class Account < FakeRecord
  def saldo
    { cents: cents, currency: currency }
  end

  def fibonacci
    [1, 1, 2, 3, 5, 8, 13, 21]
  end
end

class Album < FakeRecord
  attr_accessor :songs
end

class Song < FakeRecord
end


### Populate models with some data:

$time = Time.at(1425560620).utc

$users = [
  User.new(id: 1, token: 'ma', first_name: 'Martin', last_name: 'Andert', created_at: $time - 5*365*24*60*60),
  User.new(id: 2, token: 'pm', first_name: 'Peter', last_name: 'Miller', created_at: $time - 42*24*60*60)
]

$accounts = [
  Account.new(user: $users[0], id: 1, iban: '987654321', owner: 'Me', bank_name: 'Foo Bank', cents: 100_000_00, currency: 'EUR'),
  Account.new(user: $users[1], id: 2, iban: '12345', owner: 'You', bank_name: 'Barbank', cents: -9_876_50, currency: 'USD')
]

$albums = [
  Album.new(user: $users[0], id: 1, artist: 'Metallica', title: 'Black Album'),
  Album.new(user: $users[0], id: 2, artist: 'Nirvana', title: 'Nevermind'),
  Album.new(user: $users[1], id: 3, artist: 'Pearl Jam', title: 'Ten')
]

$songs = [
  Song.new(album: $albums[0], id: 1, title: 'Enter Sandman'),
  Song.new(album: $albums[0], id: 2, title: 'Sad But True'),
  Song.new(album: $albums[0], id: 3, title: 'Nothing Else Matters'),
  Song.new(album: $albums[0], id: 4, title: 'Wherever I May Roam'),
  Song.new(album: $albums[1], id: 5, title: 'Smells Like Teen Spirit'),
  Song.new(album: $albums[1], id: 6, title: 'Come As You Are'),
  Song.new(album: $albums[1], id: 4, title: 'Polly')
]

$users[0].account = $accounts[0]
$users[1].account = $accounts[1]

$users[0].albums = $albums[0..1]
$users[1].albums = $albums[2..2]

$albums[0].songs = $songs[0..3]
$albums[1].songs = $songs[4..6]
$albums[2].songs = []

$viewer = $users[0]


### Graph nodes:

class UserField < GQL::Field
  cursor :token

  # define some fields
  string  :id, -> { target.token } # use `target` to access the underlying record
  string  :first_name # maps directly to `target.first_name`
  string  :last_name
  boolean :is_admin, -> { target.admin? }

  object  :account, as: 'AccountField'
       # must use a string here  ^  b/c AccountField constant is not yet defined

  connection :albums, item_class: 'AlbumField'
                         # same here  ^

  timestamp :created_at
  #   ^   using custom field type here (see below for definition)

  string :full_name do
    target.first_name + ' ' + target.last_name
  end
end

class AlbumField < GQL::Field
  cursor :id

  number      :id
  object      :user, as: UserField
  string      :artist
  string      :title
  connection  :songs, item_class: 'SongField'
end

class SongField < GQL::Field
  cursor :id

  number :id
  object :album, as: AlbumField
  string :title
end

class AccountField < GQL::Field
  cursor -> { target.iban }

  number  :id
  object  :user, as: UserField

  money   :saldo
  # ^ using custom field type here (see below for definition)

  array   :fibonacci, item_class: GQL::Number
  string  :iban
  string  :bank_name

  string  :holder, -> { target.owner }

  call :reversed_number, -> { target.number.reverse }, returns: 'GQL::String'
end


### Custom field types:

class Money < GQL::Field
  cursor -> { 'money' }

  number :cents,    -> { target[:cents] }
  string :currency, -> { target[:currency] }

  def scalar_value
    "#{'%.2f' % (target[:cents] / 100.0)} #{target[:currency]}"
  end
end

class Timestamp < GQL::Field
  call :format,     -> (format = 'default') { I18n.localize target, format: format.to_sym }, returns: 'GQL::String'
  call :add_years,  -> years { target + years * 365*24*60*60 }
  call :to_s, returns: 'GQL::String'

  number :year
  number :month
  number :day
  number :hour
  number :minute, -> { target.min }
  number :second, -> { target.sec }

  def scalar_value
    target.to_i * 1000
  end
end

# register custom field types
GQL.field_types.update money: Money, timestamp: Timestamp


### Custom list type:

class List < GQL::Field
  number  :count
  boolean :any, -> { target.any? }

  call :all, -> { target }

  call :first do |size|
    target[0...size]
  end
end

# used, when no list_class option is specified on `connection` fields
GQL.default_list_class = List


### Calls can also be defined as classes:

class UpdateUserNameCall < GQL::Call
  def execute(token, new_name)
    user = $users.find { |u| u.token == token }
    old_name = user.first_name
    user.attributes.update first_name: new_name

    {
      user: user,
      old_name: old_name,
      new_name: user.first_name
    }
  end

  returns do
    object :user, as: 'UserField'
    string :old_name
    string :new_name
  end
  #   ^  this is the same as doing it the more explicit way:
  # class Result < GQL::Field
  #   object :user,     -> { target[:user]     }, object_class: UserField
  #   string :old_name, -> { target[:old_name] }
  #   string :new_name, -> { target[:new_name] }
  # end
  # returns Result
end


### The query root class:

class RootField < GQL::Field
  connection :users,  -> { $users  }, item_class: 'UserField', list_class: 'List'
  connection :songs,  -> { $songs  }, item_class: 'SongField'
  connection :albums, -> { $albums }, item_class: 'AlbumField'

  call :user,     -> token { $users.find { |user| user.token == token } }, returns: 'UserField'
  call :viewer,   -> { $users.find { |user| user.token == context[:auth_token] } }, returns: 'UserField'
  call :account,  -> id { $accounts.find { |account| account.id == id } }, returns: 'AccountField'
  call :album,    -> id { $albums.find { |album| album.id == id } }, returns: 'AlbumField'
  call :song,     -> id { $songs.find { |song| song.id == id } }, returns: 'SongField'

  call :update_user_name, UpdateUserNameCall

  # this should normally be a connection field
  call :accounts, -> { $accounts }, returns: ['AccountField']

  call :everything, -> { ($users + $albums + $songs + $accounts).shuffle }, returns: [
    User => 'UserField', Album => 'AlbumField', Song => 'SongField', Account => 'AccountField'
  ]
end

GQL.root_class = RootField
