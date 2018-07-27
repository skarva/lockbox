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

namespace Kipeltip.Services {
    public class Collection : GLib.Object {
        public string name { get; set; }
        private Gda.Connection connection;
        private File data_dir;
        
        public Collection () {
            data_dir = Granite.Services.Paths.user_data_folder;
            Granite.Services.Paths.ensure_directory_exists (data_dir);
        }
        
        public bool open (string name, string password) {
            Granite.Services.Logger.notification ("Connecting to collection database...");
            bool exists = FileUtils.test(data_dir.get_path () + name + ".db", FileTest.EXISTS);
            string cnc = "DB_DIR=" + data_dir.get_path () + ";DB_NAME=" + name;

            try {
                connection = new Gda.Connection.from_string ("SQLite", cnc, null, Gda.ConnectionOptions.NONE);
                connection.open ();
                
                this.name = name;
                
                if (!exists) {
                    create_tables ();
                }
            } catch (Error e) {
                critical (e.message);
            }
            
            if (connection.is_opened ()) {
                return true;
            } else {
                return false;
            }
        }
        
        public List<Interfaces.Login> retrieve_list ()
                requires (connection.is_opened ())
        {
            var collection_list = new List<Interfaces.Login> ();
            try {
                var builder = new Gda.SqlBuilder (Gda.SqlStatementType.SELECT);
                builder.select_add_target ("login_entry", null);
                builder.select_add_field ("id", null, null);
                builder.select_add_field ("name", null ,null);
                
                var result = connection.statement_execute_select (builder.get_statement (), null);
                if (result.get_n_rows () > 0) {
                    var iter = result.create_iter ();
                    while (iter.move_next ()) {
                        int id = iter.get_value_for_field ("id").get_int ();
                        string name = iter.get_value_for_field ("name").get_string ();
                        var entry = new Interfaces.Login (name);
                        entry.id = id;
                        collection_list.append (entry);
                    }
                }
            } catch (Error e) {
                critical (e.message);
            }
            
            return collection_list;
        }
        
        public string retrieve_username (int id)
                requires (connection.is_opened ())
        {
            try {
                var builder = new Gda.SqlBuilder (Gda.SqlStatementType.SELECT);
                builder.select_add_target ("login_entry", null);
                builder.select_add_field ("username", null, null);
                
                var cond = builder.add_cond (Gda.SqlOperatorType.EQ, builder.add_id ("id"), builder.add_expr_value (null, id), 0);
                builder.set_where (cond);
                
                var result = connection.statement_execute_select (builder.get_statement (), null);
                if (result.get_n_rows () > 0) {
                    return result.get_value_at (result.get_column_index ("username"), 0).get_string ();
                }
            } catch (Error e) {
                critical (e.message);
            }
            
            return "";
        }
        
        public string retrieve_password (int id)
                requires (connection.is_opened ())
        {
            try {
                var builder = new Gda.SqlBuilder (Gda.SqlStatementType.SELECT);
                builder.select_add_target ("login_entry", null);
                builder.select_add_field ("password", null, null);
                
                builder.add_cond (Gda.SqlOperatorType.EQ, builder.add_id ("id"), builder.add_expr_value (null, id), 0);
                
                var result = connection.statement_execute_select (builder.get_statement (), null);
                if (result.get_n_rows () > 0) {
                    return result.get_value_at (result.get_column_index ("password"), 0).get_string ();
                }
            } catch (Error e) {
                critical (e.message);
            }
            
            return "";
        }
        
        public int add_login_entry (Interfaces.Login login_entry)
                requires (connection.is_opened ())
        {
            try {
                var builder = new Gda.SqlBuilder (Gda.SqlStatementType.INSERT);
                builder.set_table ("login_entry");
                builder.add_field_value_as_gvalue ("name", login_entry.name);
                builder.add_field_value_as_gvalue ("username", login_entry.username);
                builder.add_field_value_as_gvalue ("password", login_entry.password);
                
                var statement = builder.get_statement ();
                
                Gda.Set last_row;
                
                if (connection.statement_execute_non_select (statement, null, out last_row) == 1) {
                    return last_row.get_holder_value ("+0").get_int ();
                } else {
                    return -1;
                }
            } catch (Error e) {
                critical (e.message);
            }
            
            return -1;
        }
        
        public bool remove_login_entry (int id) 
                requires (connection.is_opened ())
        {
            try {
                var builder = new Gda.SqlBuilder (Gda.SqlStatementType.DELETE);
                builder.set_table ("login_entry");
                var id_field = builder.add_id ("id");
                var id_param = builder.add_expr_value (null, id);
                builder.set_where (builder.add_cond (Gda.SqlOperatorType.EQ, id_field, id_param, 0));
                
                var statement = builder.get_statement ();
                
                if (connection.statement_execute_non_select (statement, null, null) == 1) {
                    return true;
                } else {
                    return false;
                }
            } catch (Error e) {
                critical (e.message);
            }
            
            return false;
        }
        
        private void create_tables ()
                requires (connection.is_opened ())
        {
            Granite.Services.Logger.notification ("Creating database tables...");
            Error e = null;

            var operation = Gda.ServerOperation.prepare_create_table (connection,"login_entry", e,
                "id", typeof (int), Gda.ServerOperationCreateTableFlag.PKEY_AUTOINC_FLAG,
                "name", typeof (string), Gda.ServerOperationCreateTableFlag.NOT_NULL_FLAG,
                "username", typeof (string), Gda.ServerOperationCreateTableFlag.NOT_NULL_FLAG,
                "password", typeof (string), Gda.ServerOperationCreateTableFlag.NOT_NULL_FLAG);
            if (e != null) {
                critical (e.message);
            } else {
                try {
                    operation.perform_create_table ();
                } catch (Error e) {
                    if (e.code != 1) {
                        critical (e.message);
                    }
                }
            }
        }
    }
}
