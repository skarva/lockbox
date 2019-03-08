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

namespace Lockbox.Interfaces {
    public class Login : Item, Secret.Item {
        public string id { get; set; }
        public string name { get; set; }
        public string uri { get; set; }
        public string username { get; set; }
        public string password { get; set; }

        public Login (string id="", string name="", string uri="", string username="", string password) {
            this.id = id;
            this.name = name;
            this.uri = uri;
            this.username = username;
            this.password = password;
        }

        public static bool is_login(Secret.Item item) {
            string name = item.get_schema_name ();
            if (name == epiphany_schema ().name) {
                return true;
            } else {
                return false;
            }
        } 

        public static Secret.Schema epiphany_schema () {
            var schema = new Secret.Schema ("org.epiphany.FormPassword", Secret.SchemaFlags.NONE,
                    "id", Secret.SchemaAttributeType.STRING,
                    "uri", Secret.SchemaAttributeType.STRING,
                    "target_origin", Secret.SchemaAttributeType.STRING,
                    "form_username", Secret.SchemaAttributeType.STRING,
                    "form_password", Secret.SchemaAttributeType.STRING,
                    "username", Secret.SchemaAttributeType.STRING,
                    "server_time_modified", Secret.SchemaAttributeType.STRING);
            return schema;
        }
    }
}
