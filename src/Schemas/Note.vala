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

namespace Lockbox.Schemas {
    const string note_schema_name = "com.github.skarva.lockbox.notes";

    public static bool is_note (Secret.Item item) {
        string name = item.get_schema_name ();

        if (name == null || name.length == 0)
            return false;

        return name == note_schema_name;
    }

    public static Secret.Schema note () {
        var schema = new Secret.Schema (note_schema_name, Secret.SchemaFlags.NONE,
                "id", Secret.SchemaAttributeType.STRING);

        return schema;
    }
}
