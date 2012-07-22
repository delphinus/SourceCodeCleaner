package SourceCodeCleaner::L10N::ja;

use strict;
use base 'SourceCodeCleaner::L10N::en_us';
use vars qw ( %Lexicon );

%Lexicon = (
	'It is plug in which a little just makes the source code clean.' => '再構築されるファイルの余分な改行や空行、空白などをすべて削除します。',
	
	'Enable this plugin' => '全般設定',
	'Enable Source Code Cleaner' => 'ソースコードクリーナーを有効にする',

	'Set of items to be applied' => '各項目の設定',
	'Applied to the \'li\' element' => 'li 要素に適用する',
	'Applied to the \'pre\' element' => 'pre 要素に適用する',
	'Remove all newlines' => 'すべての改行を取り除く',

	'Other Features' => 'その他の機能',
	'Add tabindex to Input and Textarea' => 'tabindexを追加する',
	'Add accesskey to Elements' => 'accesskeyを追加する',
	'Initial value' => '初期値',
	'Initial value 0-9' => '初期値（半角数字）',
	'Initial value 0-9,a-z' => '初期値（半角英数 1字）',
	'Accesskey is equal to tabindex' => 'accesskeyにtabindexと同じ数字にする',
	'Add external link class' => '外部リンクにclassを追加する',
);

1;