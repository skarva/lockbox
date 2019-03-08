/*
* Copyright (c) 2019 skärva LLC. <https://skarva.tech>
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

namespace Lockbox {
    public enum CollectionType { LOGIN, NOTE }
}

namespace Lockbox.Services {
    public class CollectionManager {
        private Secret.Service service;
        private Secret.Collection default_login_collection;
        private Secret.Collection default_notes_collection;
        private bool ready;

        public signal void loaded ();
        public signal void opened ();
        public signal void added (string id);

        // This should open the Login collection and, if it exists, the secure note collection
        public CollectionManager () {
            ready = false;
            Secret.Service.get.begin (Secret.ServiceFlags.LOAD_COLLECTIONS, new Cancellable (), (obj, res) => {
                try {
                    service = Secret.Service.get.end (res);
                    var collections = service.get_collections ();
                    var found_collection = false;
                    foreach (var collection in collections) {
                        if (collection.label == "Login") {
                            default_login_collection = collection;
                            found_collection = true;
                        }
                        else if (collection.label == "Notes") {
                            default_notes_collection = collection;
                            found_collection = true;
                        }
                    }

                    if (found_collection) {
                        loaded ();
                    }
                } catch (Error e) {
                    critical (e.message);
                }
            });
        }

        public void close () {
            Secret.Service.disconnect ();
        }

        public void add_item (Interfaces.Item item, CollectionType type) {
            if (type == LOGIN) {
                var login = item as Interfaces.Login;
                var timestamp = get_real_time () / 1000;
                var attributes = new HashTable<string, string> (str_hash, str_equal);
                attributes.insert ("id", login.id);
                attributes.insert ("uri", login.uri);
                attributes.insert ("target_origin", "");
                attributes.insert ("form_username", "");
                attributes.insert ("form_password", "");
                attributes.insert ("username", login.username);
                attributes.insert ("server_time_modified", timestamp.to_string ());
                service.store.begin (Interfaces.Login.epiphany_schema (), attributes,
                        default_login_collection.g_object_path, login.name,
                        new Secret.Value (login.password, login.password.length, "text/plain"),
                        new Cancellable (), added (login.id));
            } else if (type == NOTE) {
                var note = item as Interfaces.Note;
                var attributes = new HashTable<string, string> (str_hash, str_equal);
                attributes.insert ("id", note.id);
                attributes.insert ("name", note.name);
                attributes.insert ("content", note.content);
                service.store.begin (Interfaces.Note.schema (), attributes, 
                        default_notes_collection.g_object_path, note.name,
                        new Secret.Value (note.content, note.content.length, "text/plain"),
                        new Cancellable ());
            }
        }

        public List<Secret.Item> get_items (CollectionType type) {
            var collection_items = new List<Secret.Item> ();
            var relevant_items = new List<Secret.Item> ();
            var schema = "none";
            if (type == LOGIN) {
                collection_items = default_login_collection.get_items ();
                schema = Interfaces.Login.epiphany_schema ().name;
            } else if (type == NOTE && default_notes_collection != null) {
                collection_items = default_notes_collection.get_items ();
                schema = Interfaces.Note.schema ().name;
            }

            foreach (var item in collection_items) {
                if (item.get_schema_name () == schema) {
                    relevant_items.append (item);
                }
            }

            return relevant_items;
        }
    }
} // Lockbox.Services
