# Keycloak client administration

This guide explains how to create a delegated administrator for a client (site eg. `OpenELIS 1`), create
the group of users managed by that administrator, and configure Keycloak
policies and permissions so that each administrator can manage only the intended
users and client roles.

## What the configuration is intended to achieve

For each site, such as OpenELIS 1 or OpenELIS 2, the configuration has:

| Purpose | OpenELIS 1 | OpenELIS 2 |
| --- | --- | --- |
| Client | `openelis-1` | `openelis-2` |
| Administrator | `openelis-1-admin` | `openelis-2-admin` |
| Managed-user group | `OpenELIS 1 Managed Users` | `OpenELIS 2 Managed Users` |
| Administrator policy | `OpenELIS 1 Administrator` | `OpenELIS 2 Administrator` |
| Group permission | `Manage OpenELIS 1 User Group` | `Manage OpenELIS 2 User Group` |
| Client-role permission | `Assign OpenELIS 1 Client Roles` | `Assign OpenELIS 2 Client Roles` |

Both delegated administrators are members of `Delegated Administrator
Accounts`. This protected group separates administrator accounts from ordinary
managed users.

## Important concepts

- A **policy** answers _who is eligible?_
- A **permission** answers _what resource and administrative actions are
  allowed?_

## Before starting

Sign in to the Keycloak Admin Console with a realm administrator account `admin`, not
with a delegated administrator account.

Then verify:

1. The active realm is `ozone`.
2. The target application (site) client already exists under **Clients** Eg.`OpenELIS 1`.
3. The client has roles under **Clients > target client (openelis-1) > Roles**.
4. Fine-grained administrative permissions are enabled for the realm.

## Naming convention

Use names that state the subject and purpose without requiring knowledge of
internal IDs:

| Object | Recommended pattern                                  | Example |
| --- |------------------------------------------------------| --- |
| Administrator username | `<site>-admin`                                       | `openelis-1-admin` |
| Managed-user group | `<Site Name> Managed Users`                          | `OpenELIS 1 Managed Users` |
| Administrator policy | `<Site Name> Administrator`                          | `OpenELIS 1 Administrator` |
| Negative policy | `Exclude <Site Name> Administrator`                  | `Exclude OpenELIS 1 Administrator` |
| Group permission | `Manage <Site Name> User Group`                      | `Manage OpenELIS 1 User Group` |
| Client permission | `Assign <Site Name> Client Roles`                    | `Assign OpenELIS 1 Client Roles` |
| Cross-group protection | `Protect <Site A> Users from <Site B> Administrator` | `Protect OpenELIS 1 Users from OpenELIS 2 Administrator` |

Every group, policy, and permission should have a description stating:

- who the object applies to;
- which client or group it affects;
- which operations it permits or excludes.

## Step 1: Create the managed-user group

1. Open **Groups**.
2. Select **Create group**.
3. Enter a meaningful name, for example `OpenELIS 3 Managed Users`.
4. Save the group.
5. Add a description such as:

   > Users whose OpenELIS 3 access and and roles are managed by the
   > OpenELIS 3 delegated administrator.
   

The group should describe the users being managed, not the administrator. Avoid
ambiguous names such as `admin-3-users`, `client-a-users`, or `group-1`.

## Step 2: Create the protected administrator group

Only one shared protected group is normally required.

1. Open **Groups**.
2. Create `Delegated Administrator Accounts` if it does not already exist.
3. Add this description:

   > Protected accounts that are admins of other clients (sites).

4. Do not place ordinary application users in this group.
5. Go to `Role Mapping` tab and assign the following `Client roles`
   - `query-groups`
   - `query-users`
   - `query-clients`

This group makes administrator accounts easy to identify and keeps them separate
from managed users.

## Step 3: Create the delegated administrator user

1. Open **Users** and select **Create new user**.
2. Set a meaningful username Eg. `openelis-3-admin`.
3. Set a recognizable first name, last name, and email address.
4. Save it.
5. Open the user's **Credentials** tab.
6. Set a password.
7. Open **Groups** for the user.
8. Join the user to `Delegated Administrator Accounts`.

## Step 4: Create the positive administrator policy

Create one positive user policy for each delegated administrator.

1. Open **Permissions > Policies**.
2. Select **Create policy**.
3. Select the **User** policy type.
4. Name it, for example `OpenELIS 3 Administrator`.
5. Add a description:

   > Grants the associated permissions only to the delegated administrator for
   > OpenELIS 3.

6. Select the `openelis-3-admin` user.
7. Set **Logic** to `Positive`.
8. Save the policy.

This policy identifies the administrator. It does not grant access until it is
applied by a permission.

## Step 5: Update the shared delegated-administrator policy

The shared policy is used for operations that every delegated administrator
needs, such as limited user management or assigning shared Odoo roles.

1. Open the user policy named `All OpenELIS Delegated Administrators`.
2. Add the new delegated administrator user `openelis-3-admin`.
3. Confirm **Logic** is `Positive`.
4. Save it.

## Step 6: Create the client-role assignment permission

This permission lets an administrator see one client and assign roles belonging
to that client.

1. Open **Permissions**.
2. Create a **Clients permission**.
3. Name it `Assign OpenELIS 3 Client Roles`.
4. Add a description:

   > Allows the OpenELIS 3 delegated administrator to view the OpenELIS 3
   > client and assign its client roles.

5. Select the resource representing the `openelis-3` client. Don't select `All Clients`.
6. Select only these scopes:

   - `view`
   - `map-roles`

7. Apply the `OpenELIS 3 Administrator` policy.
8. Save the permission.

## Step 7: Create the managed-group permission

This permission gives the administrator control over the correct managed-user
group.

1. Create **Groups permission**.
2. Name it `Manage OpenELIS 3 User Group`.
3. Add a description:

   > Allows the OpenELIS 3 delegated administrator to view the OpenELIS 3
   > managed-user group and manage its membership.

4. Select the resource for `OpenELIS 3 Managed Users`.
5. Select:

   - `view`
   - `view-members`
   - `manage-members`
   - `manage-membership`

6. Apply the `OpenELIS 3 Administrator` policy.
7. Save the permission.

## Step 8: Grant Admin users to view all users

Verify:

1. Open `Manage All Users` permission.
2. Required scopes:

   - `view`
   - `manage`
   - `map-roles`
   - `manage-group-membership`

3. Applies `All OpenELIS Delegated Administrators`.

## Step 9: Create negative policies for isolation

For a new administrator:

1. Create a **User** policy.
2. Name it `Exclude OpenELIS 3 Administrator`.
3. Add a description:

   > Excludes the OpenELIS 3 delegated administrator account from the
   > associated permissions.

4. Select `openelis-3-admin`.
5. Set **Logic** to `Negative`.
6. Save it.
7. Add the user (`openelis-3-admin`) to the existing `Exclude All Delegated Administrators` policy.

## Step 10: Protect each managed group from other administrators

For every client administrators, add a cross-group protective permission.

For example, to protect OpenELIS 3 users from other administrator:

1. Create a **Groups permission**.
2. Name it `Protect OpenELIS 3 Users from other Administrator`.
3. Add description:
   > Prevents the delegated administrator from viewing or changing the OpenELIS 3 managed-user group and its membership.
4. Select scopes:

   - `view`
   - `view-members`
   - `manage-members`
   - `manage-membership`
5. Select the `OpenELIS 3 Managed Users` group.
6. Policies `Exclude OpenELIS 1 Administrator`, `Exclude OpenELIS 2 Administrator`.
7. Save it.

---

## Using admins for managing sites

To onboard a new user:

1. Enter url `https://<keycloak_host:port>/admin/ozone/console`
2. Login with `openelis-3-admin` and password
3. Go to `Users` > `Add user`
4. Enter user details
5. Click on `Join Groups` and select `OpenELIS 3 Managed Users` and then `Join`
6. Click on `Create`
7. Now create `Credentials` for the newly created user
8. Add `Role mapping` (Only `Odoo` and `openelis-3` client roles will be visible)
9. Save it.

This newly created user will only be visible to either super admin of keycloak or
`openelis-3-admin` 
