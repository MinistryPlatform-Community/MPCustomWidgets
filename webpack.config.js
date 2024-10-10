// webpack.config.js
const path = require( 'path' );
const TerserPlugin = require('terser-webpack-plugin');
const CssMinimizerPlugin = require('css-minimizer-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const webpack = require('webpack');

// Import package.json to access the version
const packageJson = require('./package.json');
const { SourceMap } = require('module');

module.exports = {
    context: __dirname,
    entry: { 
        customwidget: path.resolve(__dirname, './src/index.js' )
    },
    mode: 'production',
    devtool: 'source-map',
    output: {
        path: path.resolve( __dirname, 'dist' ),
        filename: 'js/customWidget.js',
        clean: true
    },
    optimization: {
        minimize: true,
        minimizer: [
            new TerserPlugin({
                exclude: /forceLogin\.js$/,
                extractComments: false,
                terserOptions: {
                    compress: {
                        drop_console: false,
                    },
                },
            }),
        ],        
    },
    module: {
        rules: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                use: 'babel-loader',
            },
            {
                test: /\.css$/,
                use: [
                    MiniCssExtractPlugin.loader,
                    {
                        loader: 'css-loader',
                        options: {
                            sourceMap: true,
                            importLoaders: 1,
                        }
                    }
                ],
            }
        ]
    },
    plugins: [
        new MiniCssExtractPlugin({
            filename: 'css/[name].css',
        }),      
        new CopyWebpackPlugin({
            patterns: [
                /*{ from: './src/css', to: 'css' },*/
                { from: './src/forceLogin.js', to: 'js/forceLogin.js'},
            ]
        }),
        new webpack.DefinePlugin({
            'process.env.BUILD_VERSION': `${packageJson.version}`
        }),
        new webpack.BannerPlugin({
            banner: `==========================================================\nPackage Name: MinistryPlatform CustomWidgets\nVersion: ${packageJson.version}\n==========================================================\n`,
            raw: false,
        }),
    ],
};