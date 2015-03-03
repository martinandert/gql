class FakeRecord
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

class Account < FakeRecord
  def saldo
    { cents: cents, currency: currency }
  end
end

class Album < FakeRecord
  attr_accessor :songs
end

class Song < FakeRecord
end

class User < FakeRecord
  def admin?
    first_name == 'Martin'
  end

  attr_accessor :account, :albums
end

class Timestamp < GQL::Field
  call :format, returns: GQL::Fields::String do |format = 'default'|
    I18n.localize target, format: format.to_sym
  end

  call :ago, returns: GQL::Fields::String do
    'a long time ago'
  end

  fields do
    integer :year
    integer :month
    integer :day
    integer :hour
    integer :minute
    integer :second
  end

  def minute
    __target.min
  end

  def second
    __target.sec
  end

  def __raw_value
    __target.to_i * 1000
  end
end

class HasMany < GQL::Fields::Connection
  call :all do
    target
  end

  call :first do |size|
    target[0...size]
  end
end

GQL::Schema.fields.update(
  timestamp: Timestamp,
  has_many: HasMany
)

class List < GQL::Connection
  integer :count
  boolean :any

  def any
    items.any?
  end
end

class UserNode < GQL::Node
end

class SongNode < GQL::Node
end

class AlbumNode < GQL::Node
end

class AccountNode < GQL::Node
end

class MoneyNode < GQL::Node
end

class UserNode
  call :me do
    target
  end

  cursor :token

  fields do
    string :id
    string :full_name
    string :first_name
    string :last_name
    boolean :is_admin
    object :account, node_class: AccountNode
    has_many :albums, connection_class: List, node_class: AlbumNode
    timestamp :created_at
  end

  def id
    __target.token
  end

  def full_name
    __target.first_name + ' ' + __target.last_name
  end

  def is_admin
    __target.admin?
  end
end

class AccountNode
  call :reversed_number, returns: GQL::Fields::String do
    target.number.reverse
  end

  integer :id
  object :user, node_class: UserNode
  string :iban
  string :bank_name
  string :holder
  object :saldo, node_class: MoneyNode

  def cursor
    __target.iban
  end

  def holder
    __target.owner
  end
end

class MoneyNode
  float :cents
  string :currency

  def cursor
    'money'
  end

  def cents
    __target[:cents]
  end

  def currency
    __target[:currency]
  end

  def __raw_value
    "#{'%.2f' % (cents / 100.0)} #{currency}"
  end
end

class AlbumNode
  cursor :id

  integer :id
  object :user, node_class: UserNode
  string :artist
  string :title
  has_many :songs, connection_class: List, node_class: SongNode
end

class SongNode
  cursor :id

  integer :id
  object :album, node_class: AlbumNode
  string :title
end

$users = [
  User.new(id: 1, token: 'ma', first_name: 'Martin', last_name: 'Andert', created_at: Time.now - 5*365*24*60*60),
  User.new(id: 2, token: 'pm', first_name: 'Peter', last_name: 'Miller', created_at: Time.now - 42*24*60*60)
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

$viewer = $users[0]

class RootNode < GQL::Node
  call :viewer, returns: UserNode do
    $users.find { |user| user.token == context[:auth_token] }
  end

  call :user, returns: UserNode do |token|
    $users.find { |user| user.token == token }
  end

  call :account, returns: AccountNode do |id|
    $accounts.find { |account| account.id == id }
  end

  call :album, returns: AlbumNode do |id|
    $albums.find { |album| album.id == id }
  end

  call :song, returns: SongNode do |id|
    $songs.find { |song| song.id == id }
  end

  call :users, returns: [HasMany, List, UserNode] do
    $users
  end

  call :albums, returns: [HasMany, List, AlbumNode] do
    $albums
  end

  call :songs, returns: [List, SongNode] do
    $songs
  end

  call :accounts, returns: [AccountNode] do
    $accounts
  end
end

GQL::Schema.root = RootNode
