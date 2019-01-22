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

namespace Lockbox.Services {
    public class CollectionManager {
        public string current_label { get; set; }
        private Secret.Service service;
        private Secret.Collection default_login_collection;
        private Secret.Collection default_notes_collection;
        private bool ready;

        public signal void loaded ();
        public signal void opened ();
        public signal void failed (string message);

        // This should open the Login collection and, if it exists, the secure note collection
        public CollectionManager () {
            current_label = "null";
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
/*
        // Deprecated
        public void open (string name) {
            if (!ready) {
                failed ("Could not load collections");
            }

            foreach (var c in collection_list) {
                if (c.label == name) {
                    collection = c;
                }
            }

            if (collection == null) {
                Secret.Collection.create.begin (service, name, null, Secret.CollectionCreateFlags.COLLECTION_CREATE_NONE, new Cancellable (), (obj, res) => {
                    try {
                        collection = Secret.Collection.create.end (res);
                        this.current_label = collection.label;
                        refresh_collection_list ();
                        opened ();
                    } catch (Error e) {
                        failed ("Failed to create collection! " + e.message);
                    }
                });
            } else {
                var list = new List<DBusProxy> ();
                list.append (collection);
                service.unlock.begin (list, new Cancellable (), (obj, res) => {
                    try {
                        var unlocked = new List<DBusProxy> ();
                        service.unlock.end (res, out unlocked);
                        if (unlocked.length () > 0) {
                            this.current_label = collection.label;
                            opened ();
                        }
                    } catch (Error e) {
                        failed ("Failed to unlock collection! "  + e.message);
                    }
                });
            }
        }*/

        public void close () {
            Secret.Service.disconnect ();
        }
    }
} // Lockbox.Services
