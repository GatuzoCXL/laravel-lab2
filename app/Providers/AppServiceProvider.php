<?php

namespace App\Providers;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\URL;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        // Parse database URL for Render.com
        if ($databaseUrl = env('DATABASE_URL')) {
            $url = parse_url($databaseUrl);
            config([
                'database.connections.pgsql.host' => $url['host'] ?? null,
                'database.connections.pgsql.port' => $url['port'] ?? null,
                'database.connections.pgsql.database' => ltrim($url['path'] ?? '', '/'),
                'database.connections.pgsql.username' => $url['user'] ?? null,
                'database.connections.pgsql.password' => $url['pass'] ?? null,
            ]);
        }
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        if (env('APP_ENV') !== 'local') {
            URL::forceScheme('https');
        }
    }
}
