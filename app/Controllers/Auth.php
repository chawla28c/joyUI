<?php

namespace App\Controllers;

use App\Models\UserModel;
use CodeIgniter\HTTP\ResponseInterface;

class Auth extends BaseController
{
    protected $helpers = ['form', 'url'];

    public function index(): ResponseInterface
    {
        $session = session();
        $id = $session->get('joy_user_id');
        $user = null;
        if ($id !== null) {
            $user = model(UserModel::class)->activeAccount()
                ->select('joy_users.username')->find($id);
            if ($user === null) {
                $session->remove('joy_user_id');
            }
        }

        return $this->response->setHeader('Cache-Control', 'no-store')
            ->setBody(view('auth/login', [
                'user' => $user,
                'error' => $session->getFlashdata('login_error'),
            ]));
    }

    public function login(): ResponseInterface
    {
        $session = session();
        if (time() < (int) $session->get('joy_next_login')) {
            return redirect()->to(site_url('/'))->with('login_error', 'Wait a few seconds before trying again.');
        }
        $session->set('joy_next_login', time() + 3);

        $email = $this->request->getPost('email');
        $password = $this->request->getPost('password');
        if (!is_string($email) || !is_string($password) ||
            strlen(trim($email)) > 191 || !filter_var(trim($email), FILTER_VALIDATE_EMAIL) ||
            $password === '' || strlen($password) > 72 || str_contains($password, "\0")) {
            return redirect()->to(site_url('/'))->with('login_error', 'Invalid email or password.');
        }

        $user = model(UserModel::class)->activeAccount()
            ->select('joy_users.id_user, joy_users.password_hash')
            ->where('joy_users.email', trim($email))->first();
        $hash = $user['password_hash'] ?? '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.';
        if (!password_verify($password, $hash) || $user === null) {
            return redirect()->to(site_url('/'))->with('login_error', 'Invalid email or password.');
        }

        $session->regenerate(true);
        $session->set('joy_user_id', (int) $user['id_user']);
        $session->remove('joy_next_login');
        return redirect()->to(site_url('/'))->withCookies();
    }

    public function logout(): ResponseInterface
    {
        session()->destroy();
        return redirect()->to(site_url('/'))->withCookies();
    }
}
