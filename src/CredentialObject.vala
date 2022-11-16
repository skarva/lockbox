/*
 * SPDX-License-Identifier: LGPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 skarva llc (https://skarva.tech)
 */

public class LockBox.CredentialObject : SecretObject {
    public string url { get; set; }
    public string username { get; set; }

    public CredentialObject (string id) {
        Object (id: id);
    }
}
