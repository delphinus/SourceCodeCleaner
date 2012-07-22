package MT::Plugin::SourceCodeCleaner;

use strict;
use base qw( MT::Plugin );

my $plugin = MT::Plugin::SourceCodeCleaner->new({
    id          => 'sourcecodecleaner',
    key         => __PACKAGE__,
    name        => 'Source Code Cleaner',
    description => '<__trans phrase="It is plug in which a little just makes the source code clean.">',
    version     => '2.0',
    author_name => 'Tomohiro Okuwaki',
    author_link => 'http://www.tinybeans.net/blog/',
    plugin_link => 'http://www.tinybeans.net/blog/download/mt-plugin/source-code-cleaner.html',
    l10n_class  => 'SourceCodeCleaner::L10N',
    blog_config_template => 'blog_config.tmpl',
    settings    => new MT::PluginSettings([
    	['opt_active', {Default => 1, Scope => 'blog'}],
    	['opt_li',     {Default => 1, Scope => 'blog'}],
    	['opt_pre',    {Default => 0, Scope => 'blog'}],
    	['opt_all',    {Default => 0, Scope => 'blog'}],
    	['opt_tabindex',     {Default => 0, Scope => 'blog'}],
    	['opt_tabindex_num', {Default => 1, Scope => 'blog'}],
    	['opt_accesskey',    {Default => 0, Scope => 'blog'}],
    	['opt_accesskey_str', {Default => 'a', Scope => 'blog'}],
    	['opt_tab_acc', {Default => 0, Scope => 'blog'}],
    	['opt_exlink',       {Default => 0, Scope => 'blog'}],
    	['opt_exlink_class', {Default => 'exlink', Scope => 'blog'}],
		]),
    registry => {
    	tags => {
	  		function => {
	  			'Cleaner' => \&cleaner_tag,
	  		},
	  	},
    	callbacks => {
    		'build_page' => \&source_code_cleaner,
    	},
    }
});
MT->add_plugin($plugin);

#
# Function Tag
#

sub cleaner_tag {
	my ($ctx, $args) = @_;
	
	my $html = $args->{'html'};
	my $out;
	
	if ($html) {
		$out = '<!-- Exc SCC -->';
	} else {
		$out = '/* Exc SCC */';
	}
	return $out;
}

#
# Callback
#

my $tab_count;
my $accesskey_str;
my $inner_url;
my $exlink;

sub source_code_cleaner {
	my ($cb, %args) = @_;
	
	my $content_ref = $args{content};
	my $ctx = $args{context};
	my $blog = $args{blog}; 
	my $blog_url = $blog->site_url;
	my $blog_id = $ctx->stash('blog_id');

	# Not applicable
	
	if ($$content_ref =~ /(\/\* Exc SCC \*\/)|(<\!-- Exc SCC -->)/g) {
		$$content_ref =~ s/(\/\* Exc SCC \*\/)|(<\!-- Exc SCC -->)//g;
		return;
	}

	# Get the value of option

	my $option_active = $plugin->get_setting('opt_active', $blog_id);
	my $option_li = $plugin->get_setting('opt_li', $blog_id);
	my $option_pre = $plugin->get_setting('opt_pre', $blog_id);
	my $option_all = $plugin->get_setting('opt_all', $blog_id);

	my $option_tabindex = $plugin->get_setting('opt_tabindex', $blog_id);
	my $option_tabindex_num = $plugin->get_setting('opt_tabindex_num', $blog_id);

	my $option_accesskey = $plugin->get_setting('opt_accesskey', $blog_id);
	my $option_accesskey_str = $plugin->get_setting('opt_accesskey_str', $blog_id);

	my $option_tab_acc = $plugin->get_setting('opt_tab_acc', $blog_id);

	my $option_exlink = $plugin->get_setting('opt_exlink', $blog_id);
	my $option_exlink_class = $plugin->get_setting('opt_exlink_class', $blog_id);

	$tab_count = $option_tabindex_num;
	$accesskey_str = $option_accesskey_str;
	$inner_url = $blog_url;
	$exlink = $option_exlink_class;

	# Regular expression

	if ($option_active) {

		# Attribute : tabindex and accesskey
		if ($option_tabindex && $option_accesskey && $option_tab_acc) {
			$$content_ref =~ s/(<input|<textarea|<button)([^>]*>)/add_tabindex_accesskey($&)/ge;
			$$content_ref =~ s/(<legend)([^>]*>)/add_accesskey($&)/ge;
		} elsif ($option_tabindex) {
			if ($option_accesskey) {
				$$content_ref =~ s/(<input|<textarea|<button)([^>]*>)/add_tabindex($&)/ge;
				$$content_ref =~ s/(<input|<textarea|<button|<legend)([^>]*>)/add_accesskey($&)/ge;
			} else {
				$$content_ref =~ s/(<input|<textarea|<button)([^>]*>)/add_tabindex($&)/ge;
			}
		} elsif ($option_accesskey) {
			$$content_ref =~ s/(<input|<textarea|<button|<legend)([^>]*>)/add_accesskey($&)/ge;
		}

		# Attribute : external link class
		if ($option_exlink) {
			$$content_ref =~ s/<a[^>]*href="http[^"]*"[^>]*>/external_link($&)/ge;

		}
		
		# Element : pre - escape
		unless ($option_pre) {
			$$content_ref =~ s/<pre[\s\S]*?\/pre>/exc_pre($&)/ge;
		}
		$$content_ref =~ s/(\s+\n)|(\n+)/\n/g;
		# Element : li
		if ($option_li) {
			$$content_ref =~ s/\s+<\/li>/<\/li>/g;
		}
		
		# Remove all newlines
		if ($option_all) {
			$$content_ref =~ s/^[ |\t]*//gm;
			$$content_ref =~ s/\n/ /g;
		}

		# Element : pre - return
		unless ($option_pre) {
			if ($option_all) {
				$$content_ref =~ s/sccleaner__sccleaner/\n/g;		
				$$content_ref =~ s/(sccleaner_)|(_sccleaner)//g;		
			} else {
				$$content_ref =~ s/(sccleaner_)|(_sccleaner)//g;		
			}
		}
	}
}

sub get_setting {
	my $plugin = shift;
	my ($value, $blog_id) = @_;
	my %plugin_param;
	
	$plugin->load_config(\%plugin_param, 'blog:'.$blog_id);
	$value = $plugin_param{$value};
	unless ($value) {
		$plugin->load_config(\%plugin_param, 'system');
		$value = $plugin_param{$value};
	}
	$value;
}

sub exc_pre {
	my ($str) = @_;
	$str =~ s/^[ |\t]*/sccleaner_$&_sccleaner/gm;
	$str =~ s/([<|\/])(pre)([>| ])/$1sccleaner_pre_sccleaner$3/g;
	$str =~ s/\n/sccleaner__sccleaner\n/g;	
	return $str;
}

sub add_tabindex {
	my ($str) = @_;
	if ($str =~ /hidden|tabindex/g) {return $str;} 
	$str =~ s/input|textarea|button/$& tabindex=\"$tab_count\"/;
	$tab_count++;
	return $str;
}

sub add_accesskey {
	my ($str) = @_;
	if ($str =~ /hidden|accesskey/g) {return $str;} 
	$str =~ s/input|textarea|button|legend/$& accesskey=\"$accesskey_str\"/;
	$accesskey_str++;
	return $str;
}

sub add_tabindex_accesskey {
	my ($str) = @_;
	if ($str =~ /hidden|tabindex|accesskey/g) {return $str;} 
	$str =~ s/input|textarea|button/$& tabindex=\"$tab_count\" accesskey=\"$tab_count\"/;
	$tab_count++;
	return $str;
}

sub external_link {
	my ($str) = @_;
	unless ($str =~ /localhost/g) {
		if ($str =~ /class="/g) {
			$str =~ s/(class=")([^"]+)(")/$1$2 $exlink$3/;
		} else {
			$str =~ s/<a /<a class="$exlink" /;
		}
		return $str;
	} else {
		return $str;
	}
}


1;
