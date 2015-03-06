class FakeRecord
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

class User < FakeRecord
  def admin?
    first_name == 'Martin'
  end

  attr_accessor :account, :albums
end

class Timestamp < GQL::Field
  call :format, GQL::String, -> (format = 'default') { I18n.localize target, format: format.to_sym }
  call :ago, GQL::String, -> { 'a long time ago' }
  call :to_s, GQL::String
  call :add_years, -> (years) { target + years * 365*24*60*60 }

  number :year
  number :month
  number :day
  number :hour
  number :minute, -> { target.min }
  number :second, -> { target.sec }

  def raw_value
    target.to_i * 1000
  end
end

GQL.field_types.update timestamp: Timestamp

class List < GQL::Connection
  number  :count
  boolean :any, -> { target.any? }

  call :all,   -> { target }
  call :first, -> size { target[0...size] }
end

GQL.default_list_class = List

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
  cursor :token

  string      :id,        -> { target.token }
  string      :full_name, -> { target.first_name + ' ' + target.last_name }
  string      :first_name
  string      :last_name
  boolean     :is_admin,  -> { target.admin? }
  object      :account,     node_class: AccountNode
  connection  :albums,      item_class: AlbumNode
  timestamp   :created_at
end

class AccountNode
  cursor -> { target.iban }

  number  :id
  object  :user,      node_class: UserNode
  object  :saldo,     node_class: MoneyNode
  array   :fibonacci, item_class: GQL::Number
  string  :iban
  string  :bank_name
  string  :holder, -> { target.owner }

  call :reversed_number, GQL::String, -> { target.number.reverse }
end

class MoneyNode
  cursor -> { 'money' }

  number :cents,    -> { target[:cents] }
  string :currency, -> { target[:currency] }

  def raw_value
    "#{'%.2f' % (target[:cents] / 100.0)} #{target[:currency]}"
  end
end

class AlbumNode
  cursor :id

  number      :id
  object      :user, node_class: UserNode
  string      :artist
  string      :title
  connection  :songs, item_class: SongNode
end

class SongNode
  cursor :id

  number :id
  object :album, node_class: AlbumNode
  string :title
end

$time = Time.at(1425560620)

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

require 'active_support/concern'

module UpdateUserNameCall
  extend ActiveSupport::Concern

  included do
    call :update_user_name, Result, -> (token, new_name) {
      user = $users.find { |user| user.token == token }
      old_name = user.first_name
      user.attributes.update first_name: new_name

      {
        user: user,
        old_name: old_name,
        new_name: user.first_name
      }
    }
  end

  class Result < GQL::Node
    object :user,     -> { target[:user]     }, node_class: UserNode
    string :old_name, -> { target[:old_name] }
    string :new_name, -> { target[:new_name] }
  end
end

class RootNode < GQL::Node
  include UpdateUserNameCall

  call :viewer,   UserNode,         -> { $users.find { |user| user.token == context[:auth_token] } }
  call :user,     UserNode,         -> token { $users.find { |user| user.token == token } }
  call :account,  AccountNode,      -> id { $accounts.find { |account| account.id == id } }
  call :album,    AlbumNode,        -> id { $albums.find { |album| album.id == id } }
  call :song,     SongNode,         -> id { $songs.find { |song| song.id == id } }
  call :users,    [List, UserNode], -> { $users }
  call :albums,   [AlbumNode],      -> { $albums }

  connection :songs,    -> { $songs    }, item_class: SongNode
  connection :accounts, -> { $accounts }, item_class: AccountNode
end

GQL.root_node_class = RootNode
