<?php

namespace App\Models;

use CodeIgniter\Model;

class UserModel extends Model
{
    protected $table = 'joy_users';
    protected $primaryKey = 'id_user';

    public function activeAccount(): self
    {
        return $this->join('joy_roles', 'joy_roles.id_role = joy_users.role_id')
            ->where('joy_users.active', 1)
            ->where('joy_roles.role_status', 1);
    }
}
