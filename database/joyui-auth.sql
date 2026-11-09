-- JoyUi auth schema for a fresh MariaDB database.
-- In phpMyAdmin, select the empty joyui database before importing.
-- This schema is for the next PHP integration. The earlier PHP draft uses a different schema.
-- Seed URI values are proposed endpoints. Wire them to handlers before enabling access.

CREATE TABLE joy_roles (
    id_role INT UNSIGNED NOT NULL AUTO_INCREMENT,
    role_title VARCHAR(25) NOT NULL,
    role_description VARCHAR(250) NOT NULL DEFAULT '',
    role_status TINYINT(1) NOT NULL DEFAULT 1,
    is_superadmin TINYINT(1) NOT NULL DEFAULT 0,
    is_branchAdmin TINYINT(1) DEFAULT NULL,
    role_created_by INT UNSIGNED DEFAULT NULL,
    role_created_on DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    role_modified_by INT UNSIGNED DEFAULT NULL,
    role_modified_on DATETIME DEFAULT NULL,
    updated_at DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id_role),
    UNIQUE KEY uq_joy_roles_title (role_title)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE joy_users (
    id_user INT UNSIGNED NOT NULL AUTO_INCREMENT,
    role_id INT UNSIGNED NOT NULL,
    email VARCHAR(191) NOT NULL,
    username VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    reset_hash CHAR(64) DEFAULT NULL,
    reset_expires DATETIME DEFAULT NULL,
    activate_hash VARCHAR(191) DEFAULT NULL,
    status_message VARCHAR(255) DEFAULT NULL,
    active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    last_login DATETIME DEFAULT NULL,
    PRIMARY KEY (id_user),
    UNIQUE KEY uq_joy_users_email (email),
    UNIQUE KEY uq_joy_users_username (username),
    UNIQUE KEY uq_joy_users_reset_hash (reset_hash),
    KEY idx_joy_users_role (role_id),
    CONSTRAINT fk_joy_users_role FOREIGN KEY (role_id)
        REFERENCES joy_roles (id_role) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE auth_permissions (
    id_permission INT UNSIGNED NOT NULL AUTO_INCREMENT,
    permission_code VARCHAR(150) NOT NULL,
    uri VARCHAR(255) NOT NULL,
    http_method VARCHAR(10) NOT NULL DEFAULT 'GET',
    handler VARCHAR(255) DEFAULT NULL,
    hash CHAR(32) DEFAULT NULL,
    description VARCHAR(255) DEFAULT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    generated_by ENUM('route','manual') NOT NULL DEFAULT 'route',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    action_type ENUM('view','add','edit','delete','approve','ajax','process','report','misc') NOT NULL DEFAULT 'misc',
    context ENUM('list','single','group','system') NOT NULL DEFAULT 'system',
    PRIMARY KEY (id_permission),
    UNIQUE KEY uq_auth_permissions_code (permission_code),
    UNIQUE KEY uq_auth_permissions_uri_method (uri, http_method)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE auth_actions (
    id_action INT UNSIGNED NOT NULL AUTO_INCREMENT,
    action_code VARCHAR(150) NOT NULL,
    module_code VARCHAR(50) NOT NULL,
    screen_code VARCHAR(80) NOT NULL,
    action_name VARCHAR(150) NOT NULL,
    description VARCHAR(255) DEFAULT NULL,
    sort_order INT UNSIGNED NOT NULL DEFAULT 0,
    is_active TINYINT UNSIGNED NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT NULL,
    PRIMARY KEY (id_action),
    UNIQUE KEY uq_auth_actions_code (action_code),
    KEY idx_auth_actions_tree (module_code, screen_code, is_active, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE auth_role_actions (
    id_role_action BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    role_id INT UNSIGNED NOT NULL,
    action_id INT UNSIGNED NOT NULL,
    limit_percent DECIMAL(5,2) DEFAULT NULL,
    granted_by INT UNSIGNED DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT NULL,
    PRIMARY KEY (id_role_action),
    UNIQUE KEY uq_auth_role_actions_role_action (role_id, action_id),
    KEY idx_auth_role_actions_action (action_id),
    CONSTRAINT fk_auth_role_actions_role FOREIGN KEY (role_id)
        REFERENCES joy_roles (id_role) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_auth_role_actions_action FOREIGN KEY (action_id)
        REFERENCES auth_actions (id_action) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE auth_action_permissions (
    action_id INT UNSIGNED NOT NULL,
    permission_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (action_id, permission_id),
    KEY idx_auth_action_permissions_permission (permission_id),
    CONSTRAINT fk_auth_action_permissions_action FOREIGN KEY (action_id)
        REFERENCES auth_actions (id_action) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_auth_action_permissions_permission FOREIGN KEY (permission_id)
        REFERENCES auth_permissions (id_permission) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

START TRANSACTION;

INSERT INTO joy_roles (role_title, role_description, is_superadmin)
VALUES ('Administrator', 'Bootstrap administrator role', 1);

INSERT INTO auth_actions (action_code, module_code, screen_code, action_name, sort_order)
VALUES
    ('users.view', 'auth', 'users', 'View users', 10),
    ('users.manage', 'auth', 'users', 'Manage users', 20),
    ('roles.view', 'auth', 'roles', 'View roles', 10),
    ('roles.manage', 'auth', 'roles', 'Manage roles', 20);

INSERT INTO auth_permissions (permission_code, uri, http_method, generated_by, action_type)
VALUES
    ('users.view', '/users', 'GET', 'manual', 'view'),
    ('users.manage', '/users/save', 'POST', 'manual', 'process'),
    ('roles.view', '/roles', 'GET', 'manual', 'view'),
    ('roles.manage', '/roles/save', 'POST', 'manual', 'process');

INSERT INTO auth_action_permissions (action_id, permission_id)
SELECT a.id_action, p.id_permission
FROM auth_actions AS a
JOIN auth_permissions AS p ON p.permission_code = a.action_code
    OR (a.action_code = 'users.manage' AND p.permission_code = 'users.view')
    OR (a.action_code = 'roles.manage' AND p.permission_code = 'roles.view');

INSERT INTO auth_role_actions (role_id, action_id)
SELECT r.id_role, a.id_action
FROM joy_roles AS r
CROSS JOIN auth_actions AS a
WHERE r.role_title = 'Administrator';

COMMIT;
