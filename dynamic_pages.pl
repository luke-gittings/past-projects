#!/usr/bin/perl

use strict;
use Curses::UI;
use Data::Dumper;

my $num_fields = $ARGV[0];

my $cui = new Curses::UI( -color_support => 1 );


our $win = $cui->add('win', 'Window',-border => 1,);
our $pages = {};
our $current_page = 1;
our @field_id    = ("f");
our @fields = ();

# Create the first page
$pages->{$current_page} = { container => create_page($current_page, $cui, $win), fields => 0 };



foreach my $field (1..$num_fields)
{
	
	#push @field_id, $field;
	push(@fields, add_field( $field ));
}

# Reset current page
$current_page = 1;

$fields[0]->focus();

$cui->mainloop();

###### SUBS BELOW HERE

sub add_field
{
	my $field_num = shift;	

	# If the page has more than 3 fields on, create a new page
	if( $pages->{$current_page}->{fields} > 3)
	{
		next_btn($field_num);
		$current_page++;
		$pages->{$current_page} = { container => create_page($current_page, $cui, $win, $field_num), fields => 0 };
		if ($current_page > 1)
		{
		prev_btn($field_num);
		}

	}

	# Add a field to the current page
	my $text = $pages->{$current_page}->{container}->add("f" . $field_num, 'TextEntry',-border => 1, -y => $pages->{$current_page}->{fields} *6, -x => 3, -width => 6, -text => $field_num );

	$pages->{$current_page}->{first_field} = $text unless $pages->{$current_page}->{first_field};

	# Increment the number of fields on the current page
	$pages->{$current_page}->{fields}++;

#$text->parent()->set_focusorder(@field_id);
#$text->set_binding(\&tab_focus, "\t");
##$text->set_binding(\&tab_focus, KEY_BTAB());


return $text;

}



sub tab_focus
{
	my $fields = $_[0];
	my $key    = $_[1];

	if ($key eq "\t")
	{
		$fields->parent()->focus_next();	
	}
	else
	{
		$fields->parent()->focus_prev();
	}
	
}

sub create_page 
{
	my $page    = shift;
	my $cui     = shift;
	my $win     = shift;
	my $field_num = shift;
	my $page_ID = 'page_' . $page;
	
	my $height = $cui->height();

	my $page_container = $win->add($page_ID, 'Container',
			          -height  => $height,
				  -width   => -1,
				  -border  => 1,
				  -bfg     => "blue",
				  -text    => $page,);
 					      



        #create the button to navigate forwards through the containers 
	my $ok_btn  = $page_container->add('ok_btn', 'Buttonbox',
	-buttons => [{ -label => "ok",
	-onpress => \&ok_btn,
		  }],-y => -1, -x => 42,);
	#create a button to navigate backwards thorugh containers
	my $cancel_btn  = $page_container->add('cancel_btn', 'Buttonbox',
	-buttons  => [{ -label => "cancel",
	-onpress => \&cancel_button,
	}],-y => -1, -x => 32,);
return $page_container;
}


sub navi_btns
{
    my $change = shift;

    # increment/decrement the current page counter
      $current_page += $change;
    # check if the page counter is a key in the pages hash ( defined 
      unless (defined $pages->{$current_page})
      {
      $current_page -= $change;
      return;
      }
      # if ok, focus on the object in the pages hash (and return)
      $pages->{$current_page}->{first_field}->focus();
}



sub next_btn
{
	my $id = shift;
	my $next_btn  = $pages->{$current_page}->{container}->add('next_btn' . $id, 'Buttonbox',
	-buttons => [{ -label => "next",
	-onpress => sub { navi_btns(+1); },
	-shortcut => 'n',
	}],-y => -1, -x => 12,);
return $next_btn;
}
sub prev_btn
{
	my $id = shift;
	my $prev_btn = $pages->{$current_page}->{container}->add('prev' . $id, 'Buttonbox',
		        -buttons  => [{ -label => "prev",
			-onpress => sub { navi_btns(-1); },
			-shortcut => 'p',
			}],-y => -1, -x => 22,);
return $prev_btn;
}

sub ok_btn
{
	 my $dialog = $cui->dialog(                                                                                                                                   -message   => "you are currently on",
	-title     => "Page Number",
        -buttons   => ['ok'],);
}
sub cancel_button
{
	#button to cancel and close out of curses
	my $return = $cui->dialog(
	-message   => "Do you really want to quit?",
	-title     => "Are you sure???", 
	-buttons   => ['yes', 'no'],
	);
	exit(0) if$return;						
}

1;
