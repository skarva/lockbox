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
        private Secret.Collection default_login_collection;
        private Secret.Collection default_notes_collection;
        private bool ready;

        public signal void loaded ();
        public signal void opened ();

        // This should open the Login collection and, if it exists, the secure note collection
        public CollectionManager () {
            ready = false;
            Secret.Service.get.begin (Secret.ServiceFlags.LOAD_COLLECTIONS, new Cancellable (), (obj, res) => {
                try {
                    var service = Secret.Service.get.end (res);
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

        public List<Secret.Item> get_items (CollectionType type) {
            var collection_items = new List<Secret.Item> ();
            var relevant_items = new List<Secret.Item> ();
            var schema = "none";
            if (type == LOGIN) {
                collection_items = default_login_collection.get_items ();
                schema = Interfaces.Login.epiphany_schema ().name;
            } else if (type == NOTE && default_notes_collection != null) {
                collection_items = default_notes_collection.get_items ();
                schema = Interfaces.Note.note_schema ().name;
            }

            foreach (var item in collection_items) {
                if (item.get_schema_name () == schema) {
                    relevant_items.append (item);
                }
            }

            return relevant_items;
        }

        public void close () {
            Secret.Service.disconnect ();
        }
    }
} // Lockbox.Services
