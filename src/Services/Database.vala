/*
* Copyright (c) 2018 skärva LLC. <https://skarva.tech>
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

namespace Kipeltip {
    public class Database : GLib.Object {
        public string provider { set; get; default = "SQLite"; }
        public string uri { set; get; default = "SQLite://DB_DIR=.;DB_NAME=test"; }
        private Gda.Connection connection;

        public void open () throws Error {
            Granite.Services.Logger.notification ("Opening database connection...");
            connection.open_from_string (null, uri, null Gda.ConnectionOptions.NONE);
        }
        
        public void create_tables ()
                throws Error
                requires (connection.is_opened ()) 
        {
            
        }
    }
}
