/*
* Copyright (c) 2019 skarva LLC. <https://skarva.tech>
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
        public signal void stored (string schema_name, string id, string label);
        public signal void search_results(List<Secret.Item> items);

        public void store (Secret.Schema schema, HashTable<string, string> attributes,
                           string label, string secret) {
            Secret.password_store.begin (schema, null, label, secret,
                                         new Cancellable (), (object, result) => {
                try {
                    if (Secret.password_store.end (result)) {
                        stored (schema.name, attributes.get ("id"), label);
                    } else {
                        warning ("Could not store password" + label);
                    }
                } catch (Error e) {
                    critical (e.message);
                }
            });
        }

        public void remove () {

        }

        public void search (Secret.Schema schema, HashTable<string, string> attributes) {
            var flags = Secret.SearchFlags.ALL |
                        Secret.SearchFlags.UNLOCK |
                        Secret.SearchFlags.LOAD_SECRETS;

            Secret.Service.get.begin (Secret.ServiceFlags.LOAD_COLLECTIONS, null, (obj, res) => {
                try {
                    var service = Secret.Service.get.end (res);
                    if (service != null) {
                        service.search.begin (schema, attributes, flags, null, (obj, res) => {
                            try {
                                var item_list = service.search.end (res);
                                search_results (item_list);
                            } catch (Error e) {
                                critical (e.message);
                            }
                        });
                    } else {
                        critical ("Could not open Secret service to perform search");
                        search_results (new List<Secret.Item> ());
                    }
                } catch (Error e) {
                    critical (e.message);
                }
            });
        }
    }
} // Lockbox.Services
