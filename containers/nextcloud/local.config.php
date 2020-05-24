<?php

$CONFIG = array(
    
    'debug' => true,

    'trusted_domains' => array(
        '127.0.0.1',
        '167.71.76.76',
        'nextcloud.dmoraschi.io',
        'nextcloud.lucazini.it',
    ),

    'overwriteprotocol' =>getenv('NEXTCLOUD_PROTOCOL'),

    /**
     * Only register providers that have been explicitly enabled
     *
     * The following providers are disabled by default due to performance or privacy
     * concerns:
     *
     *  - OC\Preview\Illustrator
     *  - OC\Preview\Movie
     *  - OC\Preview\MSOffice2003
     *  - OC\Preview\MSOffice2007
     *  - OC\Preview\MSOfficeDoc
     *  - OC\Preview\OpenDocument
     *  - OC\Preview\PDF
     *  - OC\Preview\Photoshop
     *  - OC\Preview\Postscript
     *  - OC\Preview\StarOffice
     *  - OC\Preview\SVG
     *  - OC\Preview\TIFF
     *  - OC\Preview\Font
     *
     * The following providers are not available in Microsoft Windows:
     *
     *  - OC\Preview\Movie
     *  - OC\Preview\MSOfficeDoc
     *  - OC\Preview\MSOffice2003
     *  - OC\Preview\MSOffice2007
     *  - OC\Preview\OpenDocument
     *  - OC\Preview\StarOffice
     *
     * Defaults to the following providers:
     *
     *  - OC\Preview\BMP
     *  - OC\Preview\GIF
     *  - OC\Preview\HEIC
     *  - OC\Preview\JPEG
     *  - OC\Preview\MarkDown
     *  - OC\Preview\MP3
     *  - OC\Preview\PNG
     *  - OC\Preview\TXT
     *  - OC\Preview\XBitmap
     */
    'enabledPreviewProviders' => array(
        'OC\Preview\PNG',
        'OC\Preview\JPEG',
        'OC\Preview\GIF',
        'OC\Preview\HEIC',
        'OC\Preview\BMP',
        'OC\Preview\XBitmap',
        'OC\Preview\MP3',
        'OC\Preview\TXT',
        'OC\Preview\MarkDown',
        'OC\Preview\PDF',
        'OC\Preview\Photoshop',
        'OC\Preview\SVG',
        'OC\Preview\Illustrator',
        'OC\Preview\TIFF'
    ),

    'memcache.local' => '\OC\Memcache\Memcached',
    'memcached_servers' => array(
        array(getenv('MC_HOST'), 11211)
    ),

    'dbtype' => 'mysql',
    'dbhost' => getenv('MYSQL_HOST'),
    'dbname' => getenv('MYSQL_DATABASE'),
    'dbuser' => getenv('MYSQL_USER'),
    'dbpassword' => getenv('MYSQL_PASSWORD'),
    'dbtableprefix' => 'oc_'
);