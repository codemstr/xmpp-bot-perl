#!/usr/bin/perl

use strict;
use utf8;
use AnyEvent;
use AnyEvent::XMPP::Client;
use AnyEvent::XMPP::IM::Message;
use AnyEvent::XMPP::Ext::VCard;
use AnyEvent::XMPP::Ext::Disco;
use AnyEvent::XMPP::Ext::MUC;
my $vcard = AnyEvent::XMPP::Ext::VCard->new;

use WWW::Wikipedia;
use WWW::Wikipedia;

my $xmpp_message;
my $nickname = 'pi4' . $$;
my $server   = 'ip6.d-n-s.name';
my $password = '';

#use Finance::Quote;
#my $q = Finance::Quote->new;

#my %quotes  = $q->fetch("nasdaq", @stocks);
my $wiki = WWW::Wikipedia->new();

my $uname = 'pi@ip6.d-n-s.name';    # or be jabber, don't forget to change $ser>
my $passwd = '';
my $server = 'ip6.d-n-s.name';


my $j = AnyEvent->condvar;
my $con = AnyEvent::XMPP::Connection->new ();
my $cl = AnyEvent::XMPP::Client->new (debug => 0);

$cl->add_account($uname,$passwd,$server);
$con->add_extension (my $disco = AnyEvent::XMPP::Ext::Disco->new);
$con->add_extension (my $muc = AnyEvent::XMPP::Ext::MUC->new (disco => $disco));

my $room = 'pi@conference.ip6.d-n-s.name';
my $nickname = 'perlbot';

$muc->join_room($con, $room, $nickname, '');
#$muc->event (enter => $room, $room->get_me);

$con->reg_cb(
         stream_ready => sub {
                $vcard->hook_on ($con)
        }
);

$cl->reg_cb (
   session_ready => sub {
    my ($cl, $acc) = @_;
        print "Session ready!\n";
    $cl->set_presence("avaliable","Perlbotics",10);
   },
   disconnect => sub {
      my ($cl, $acc, $h, $p, $reas) = @_;
      print "Disconnected ($h:$p): $reas\n";
   },
   error => sub {
      my ($cl, $acc, $err) = @_;
      print "ERROR: " . $err->string . "\n";
   },
   message => sub {
     my ($cl, $acc, $msg) = @_;
     my ($u,$r) = split(/[\._@]/,$msg->from);
        $cl->set_presence("avaliable","avaliable",10);
     if($msg->body()=~ /^[\s]*$/) {
        print $u." is typing\n";
     } else {
        $r = $msg->make_reply;
        my $rep = &sentm($msg->body,$u);
        $r->add_body($rep);
        $r->send;
     }
    print "$u says: " . $msg->body() . "\n";
   }
);
#$vcard->retrieve ($con, $uname, sub {
#       my ($jid, $vcard, $error) = @_;
#             if ($error) {
#                warn "couldn't get vcard for $uname: " . $error->string . "\n";
#             } else {
#                print "vCard nick: ".$vcard->{NICKNAME}."\n";
#                print "Avatar hash: ".$vcard->{_avatar_hash}."\n";
#             }
#          });
#$vcard->store ($con, undef, { NICKNAME => 'net-xmpp2' }, sub {
#             my ($error) = @_;
#             if ($error) {
#                warn "upload failed: " . $error->string . "\n";
#             } else {
#                print "upload successful\n";
#             }
#          });
$disco->enable_feature ($vcard->disco_feature);
#$muc->event (enter => $room, $room->get_me);
#you can add your own keyword's, need to improve this part!
sub sentm {
    my $msg = shift;
    my $u = shift;
    my $reply;
    my @stats;
        if ($msg =~ /.stats/) {
                my @st = `neofetch`;
                my $line;
                my $n = 0;
                foreach (@st) {
                        $line .= $st[$n];
                        $n++;
                }
                if ($line ne '') {
                        return $reply = $line;
                } else {
                        return $reply = 'Failed to get stats report :(';
                }

        }
        if ($msg =~ /.sysinfo/) {
                my @info = `perl sysinfo.pl`;
                my $line;
                my $n = 0;
                foreach (@info) {
                        $line .= $info[$n];
                        $n++;
                }
                if ($line ne '') {
                        return $reply = $line;
                } else {
                        return $reply = 'You suck!';
                }
        }
        if ($msg =~ /.sys/) {
                my $sys = `inxi`;
                return $reply = $sys;
        }
        if ($msg =~ /.uptime/) {
                my $uptime = `uptime`;
                return $reply = $uptime;
        }

  if ($msg =~ /.uname/) {
                my $uname = `uname -a`;
                return $reply = $uname;
        }
        if ($msg =~ /.date/) {
                my $date = `date`;
                return $reply = $date;
        }
        if ($msg =~ /.muc (.*)/) {
                my $mucroom = $1;
                my $mucresult = $muc->join_room($con, $mucroom, $nickname, '');
                return $reply = $mucresult;
        }
        if ($msg =~ /.g (.*)/) {
                print "Googling \"$1\"\n";
                my @g = `googler $1`;
                my $str;
                my $n = 0;
                foreach (@g) {
                        $str .= $g[$n];
                        $n++;
                }
                if ($str ne '') {
                        return $reply = $str;
                }
        }
        if ($msg =~ /.w (.*)/) {
                print "searching for $1\n";
                my $q = query($1);
                if ($q) {
                        return $reply = $q;
                } else {
                        return $reply = "No results for: $1";
                }
        }

        if ($msg =~ /.online (.*)/) {
                my $status = $cl->set_presence($1,$1,1);
                return $reply = "Set online status: $1";
        }
        if ($msg =~ /.status (.*)/) {
                $cl->set_presence("online","$1",1);
                return $reply = "Set status online: $1";
        }
    if($msg=~/([hH]ow)\ware\wyou\?|([hH]i)|([hH]ey)|([Hh]ello)/) {
        return $reply="$u, $msg";
    }
    if($msg=~/([Ww]hat)|\?|([Ww]at)|(^did)/) {
        return $reply="Yeah, sure. $msg $u\?";
    }
    if($msg=~/([Ww]hy)|([Ww]hen)/) {
        return $reply="$msg what? $u.. :)";
    }
    if($msg=~/([Oo]kay)|([oO]k)/) {
        return $reply = "That's $msg $u";
    }
    if ($msg =~ /([Bb]itch)|([Ff]uck)|([Sh]it)|([Cc]unt)|([Ff]ag)|([Ss]lut)|([A>
        return $reply = "$u, what the $msg is your problem?";
    }
    else {
        return $reply = "$u says: $msg";
        #return $reply = "$ENV{'USER'} is my master $u.";
    }
}

sub query {
        my $query = shift;
        chomp($query);
        print "Wiki search: \"$query\"\n";
        #my $wiki = WWW::Wikipedia->new();

        $wiki->clean_html(1);
        my $result = $wiki->search( "$query" );
        if ($result) {
                return $result->text();
        } else {
                return "Can't find results for: \"$query\"";
        }
}


$cl->start;
$j->wait;
