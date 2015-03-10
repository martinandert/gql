class CreateApp < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string  :slug,        :null => false
      t.string  :first_name,  :null => false
      t.string  :last_name,   :null => false
    end

    add_index :people, :slug, :unique => true

    create_table :bands do |t|
      t.string  :slug,  :null => false
      t.string  :name,  :null => false
    end

    add_index :bands, :slug, :unique => true

    create_table :albums do |t|
      t.string      :slug,        :null => false
      t.references  :band,        :null => false
      t.string      :title,       :null => false
      t.date        :released_on, :null => false
    end

    add_index :albums, :slug, :unique => true
    add_index :albums, :band_id
    add_index :albums, :released_on
    add_index :albums, [:band_id, :released_on]

    create_table :songs do |t|
      t.string      :slug,          :null => false
      t.references  :album,         :null => false
      t.string      :title,         :null => false
      t.integer     :duration,      :null => false
      t.integer     :track_number,  :null => false
      t.text        :note
    end

    add_index :songs, :slug, :unique => true
    add_index :songs, :album_id
    add_index :songs, :track_number
    add_index :songs, [:album_id, :track_number], :unique => true

    create_table :memberships do |t|
      t.references  :band,          :null => false
      t.references  :member,        :null => false
      t.integer     :started_year,  :null => false
      t.integer     :ended_year
    end

    add_index :memberships, [:band_id, :member_id], :unique => true

    create_table :roles do |t|
      t.string  :slug,  :null => false
      t.string  :name,  :null => false
    end

    add_index :roles, :slug, :unique => true
    add_index :roles, :name, :unique => true

    create_table :membership_roles do |t|
      t.references :membership, :null => false
      t.references :role,       :null => false
    end

    add_index :membership_roles, [:membership_id, :role_id], :unique => true

    create_table :attributions do |t|
      t.references :song, :null => false
      t.references :writer, :null => false
    end

    add_index :attributions, [:song_id, :writer_id], :unique => true
  end
end
