/*
 * SPDX-License-Identifier: LGPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 skarva llc (https://skarva.tech)
 */

public class LockBox.SecretObject : Object {
    public string id { get; construct; }

    public SecretObject (string id) {
        Object (id: id);
    }
}
