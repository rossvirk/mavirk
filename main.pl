#!/usr/bin/perl

use utf8;
use strict;
use warnings;

#--[library's from gtk3]------------------------------------------------
use Gtk3 -init;
use Glib 'TRUE', 'FALSE';
#-----------------------------------------------------------------------








#--[settings from window]-----------------------------------------------
my $window = Gtk3::Window->new('toplevel');
$window->set_title("🐺 Mavirk | v1.0.0");
$window->set_resizable(0);
$window->set_default_size(495, 77);
$window->set_icon_from_file('./virk.png');
$window->signal_connect(destroy => sub { Gtk3->main_quit; });
#-----------------------------------------------------------------------








#--[general box's for application]--------------------------------------
my $vbox_internal_layout_general = Gtk3::Box->new('vertical', 0);
$window->add($vbox_internal_layout_general);

my $box_for_file_chooser_button = Gtk3::Box->new('vertical', 5);
$vbox_internal_layout_general->pack_end($box_for_file_chooser_button, FALSE, FALSE, 0);

my $box_for_entry_url_and_button_for_download = Gtk3::Box->new('horizontal', 5);
$box_for_file_chooser_button->pack_start($box_for_entry_url_and_button_for_download, FALSE, FALSE, 0);

my $box_list_all_servers_available = Gtk3::Box->new('vertical', 5);
$vbox_internal_layout_general->pack_start($box_list_all_servers_available, FALSE, FALSE, 0);
#-----------------------------------------------------------------------








#--[global variables]---------------------------------------------------
our $path_folder;
#-----------------------------------------------------------------------








#--[global subroutines]-------------------------------------------------
sub show_alert {
    my ($title, $message) = @_;
    my $dialog = Gtk3::MessageDialog->new(
        $window,
        'modal',
        'error',
        'close',
        $message,
    );
    $dialog->set_title($title);
    $dialog->run;
    $dialog->destroy;
}
#-----------------------------------------------------------------------








#--[adding a field for explain how to use the Mavirk]-------------------
my $label_how_to_use_mavirk = Gtk3::Label->new("A brief explanation of how the question of selecting one of the formats below (mkv or flac) works.\nIf you choose the MKV model you will be downloading a video file and not audio,\nif you choose FLAC then you will be downloading the music with the best quality\nthat the servers can find. In short, do you want video? Choose MKV. Want just the audio? Choose FLAC.");
$label_how_to_use_mavirk->set_size_request(10, -1);
$vbox_internal_layout_general->pack_start($label_how_to_use_mavirk, FALSE, FALSE, 0);
#-----------------------------------------------------------------------






#--[adding functionality to choose a predetermined folder]--------------
my $file_chooser_button = Gtk3::FileChooserButton->new('', 'select-folder');
$file_chooser_button->set_title("Mavirk | Select a folder");

$file_chooser_button->signal_connect(file_set => sub {
	my ($file) =  @_;
	$path_folder = $file->get_filename;
});

$box_for_file_chooser_button->pack_end($file_chooser_button, FALSE, FALSE, 0);
#-----------------------------------------------------------------------








#--[add components to enter a url, select format and button download]---
my $entry_url = Gtk3::Entry->new();
my $format_media = Gtk3::ComboBoxText->new();
my $button_for_download = Gtk3::Button->new_with_label('Download');

$entry_url->set_size_request(495, -1);
$format_media->append_text('mkv');
$format_media->append_text('flac');
$format_media->set_active(0);

$box_for_entry_url_and_button_for_download->pack_start($entry_url, FALSE, FALSE, 0);
$box_for_entry_url_and_button_for_download->pack_start($format_media, FALSE, FALSE, 0);
$box_for_entry_url_and_button_for_download->pack_start($button_for_download, FALSE, FALSE, 0);
#-----------------------------------------------------------------------








#--[setting functionality on entry and button]--------------------------
$button_for_download->signal_connect(clicked => sub {
	my $url =  $entry_url->get_text();
	my $command = "yt-dlp -q -f bestvideo+bestaudio --merge-output-format mkv --output \"$path_folder/%(title)s.%(ext)s\" $url";
	my $current_format = $format_media->get_active_text();
	
    if ($entry_url->get_text() eq '') {
        show_alert("Mavirk", "Please, provide a valid URL!");
    }
    elsif (!-d $path_folder) {
        show_alert("Mavirk", "The informed path is not a valid folder.");
    } else {
		 if ($url =~ m/^https:\/\/www\.youtube\.com\/(watch\?v=[A-Za-z0-9_-]{11}|playlist\?list=[A-Za-z0-9_-]{34})$/ && $current_format eq 'mkv') {
			 my $exit_status = system($command);			 
			 if ($exit_status == 0) {
				show_alert("Mavirk", "Your video was successfully installed!");
			 }
		 } elsif ($url =~ m/^https:\/\/www\.youtube\.com\/(watch\?v=[A-Za-z0-9_-]{11}|playlist\?list=[A-Za-z0-9_-]{34})$/ && $current_format eq 'flac') {
			 $command = "yt-dlp -q -f bestaudio -x --audio-format flac --output \"$path_folder/%(title)s.%(ext)s\" $url";
			 my $exit_status = system($command);
			 
			 if ($exit_status == 0) {
				show_alert("Mavirk", "Your video was successfully installed!");
			 }
		} else {
			show_alert("Mavirk", "Only YouTube URL's are supported at the moment");
		}
    }
});
#-----------------------------------------------------------------------








#--[initialize launcher]-----------------------------------------------
$window->show_all();
Gtk3::main();
#-----------------------------------------------------------------------
