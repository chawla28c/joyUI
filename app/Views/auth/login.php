<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>JoyUi · <?= $user ? 'Account' : 'Sign in' ?></title>
    <link rel="stylesheet" href="<?= esc(base_url('assets/css/joyui.css'), 'attr') ?>">
    <link rel="stylesheet" href="<?= esc(base_url('assets/css/auth.css'), 'attr') ?>">
</head>
<body class="auth-page">
<main class="panel auth-card">
    <span class="brand"><span class="logo">J</span> JoyUi</span>
    <?php if ($user): ?>
        <h1>Welcome, <?= esc($user['username']) ?></h1>
        <form method="post" action="<?= esc(site_url('logout'), 'attr') ?>">
            <?= csrf_field() ?>
            <button class="button" type="submit">Sign out</button>
        </form>
    <?php else: ?>
        <h1>Sign in</h1>
        <?php if ($error): ?><p role="alert"><?= esc($error) ?></p><?php endif ?>
        <form method="post" action="<?= esc(site_url('login'), 'attr') ?>">
            <?= csrf_field() ?>
            <label>Email
                <input type="email" name="email" autocomplete="username" maxlength="191" required>
            </label>
            <label>Password
                <input type="password" name="password" autocomplete="current-password" required>
            </label>
            <button class="button primary" type="submit">Sign in</button>
        </form>
    <?php endif ?>
</main>
</body>
</html>
