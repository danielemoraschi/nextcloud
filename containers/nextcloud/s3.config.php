<?php

if (getenv('S3_ENABLED') == 1) {
    $CONFIG = array(
        'objectstore' => array(
            'class' => '\\OC\\Files\\ObjectStore\\S3',
            'arguments' => array(
                'bucket' => getenv('S3_BUCKET'),
                'autocreate' => true,
                'key' => getenv('S3_KEY'),
                'secret' => getenv('S3_SECRET'),
                'port' => 443,
                'use_ssl' => true,
                'region' => getenv('S3_REGION'),
                'use_path_style' => false
            )
        )    
    );
}