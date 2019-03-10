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
        public Secret.Service service { get; private set; }
        public Secret.Collection default_login_collection { get; private set; }
        public Secret.Collection default_notes_collection { get; private set; }

        public signal void loaded ();
        public signal void opened ();
        public signal void added (Secret.Item item);

        // This should open the Login collection and, if it exists, the secure note collection
        public CollectionManager () {
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

        public void add_item (string name, HashTable<string, string> attributes,
                              string secret, CollectionType type) {
            if (type == LOGIN) {
                var secret_value = new Secret.Value (secret,
                                                     secret.length,
                                                     "text/plain");

                Secret.Item.create.begin (default_login_collection,
                                Schemas.epiphany (), attributes, name,
                                secret_value, Secret.ItemCreateFlags.NONE,
                                new Cancellable (), (obj, res) => {
                                    var item = Secret.Item.create.end (res);
                                    added (item);
                                });

                // service.store.begin (Schemas.epiphany (), attributes,
                //                 default_login_collection.g_object_path,
                //                 name, secret_value, new Cancellable ());

                // service.search.begin (Schemas.epiphany (), attributes,
                //                 Secret.SearchFlags.NONE, new Cancellable ()
                //                 , (obj, res) => {
                //                     var list = service.search.end (res);
                //                     item = list.nth_data(0);
                //                 });
            } else if (type == NOTE) {
                // var secret_value = new Secret.Value (secret,
                //                                      secret.length,
                //                                      "text/plain");

                // service.store.begin (Schemas.note (), attributes,
                //                 default_notes_collection.g_object_path,
                //                 name, secret_value, new Cancellable ());

                // service.search.begin (Schemas.note (), attributes,
                //                 Secret.SearchFlags.NONE, new Cancellable ()
                //                 , (obj, res) => {
                //                     var list = service.search.end (res);
                //                     item = list.nth_data(0);
                //                 });
            }
        }

        public List<Secret.Item> get_items (CollectionType type) {
            var collection_items = new List<Secret.Item> ();
            var relevant_items = new List<Secret.Item> ();
            var schema = "none";
            if (type == LOGIN) {
                collection_items = default_login_collection.get_items ();
                schema = Schemas.epiphany ().name;
            } else if (type == NOTE && default_notes_collection != null) {
                collection_items = default_notes_collection.get_items ();
                schema = Schemas.note ().name;
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
