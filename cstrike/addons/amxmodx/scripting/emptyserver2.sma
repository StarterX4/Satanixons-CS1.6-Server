#include <amxmodx>
#include <amxmisc>
#include <float>

new curtime=0,staytime=0,timelimit_empty=0,timelimit_players=0,map_empty[51],map_players[51],amx_map_memory[51]

public plugin_init()
{
	register_plugin("Empty Server2","0.8","raffe & twistedeuphoria")
//
// This plugin is based on Empty Server 1.42 by twistedeuphoria, see this
// URL for more info http://www.amxmodx.org/forums/viewtopic.php?p=55326
//
// I also got help from bmann_420 in the forum, se this URL
// http://www.amxmodx.org/forums/viewtopic.php?t=23584
//
// Change log: 0.8 2008-07-21, Fixing so that admins counts as players.
//             0.7 2006-01-21, Fixing spelling mistakes in change log text.
//             0.6 2006-01-03, Fixing nextmap possibility. Changed 
//                 to set_cvar_num for mp_timelimit. Mp_timelimit keeps 
//                 record of which map is in use (players map or empty map).
//             0.5 2005-12-31, Fixed another bug in change_maps_forplayer(),
//                 it changed back to amx_map_players every map change.
//             0.4 2005-12-31, Fixed bug in change_maps_forplayer(), 
//                 equal(curmap, map_empty) -> equal(curmap, map_players)
//             0.3 2005-12-30, changed change_maps() and 
//                 change_maps_forplayer() so it only makes changelevel if 
//                 amx_map_empty and amx_map_players are different. E.g. if 
//                 you have de_dust in both it only makes changelevel when 
//                 empty, but only mp_timelimit if a player connects.
//             0.2 2005-12-29, Started this change log.
//             0.1 2005-12-29, first version done.
//
//
// amx_staytime(in seconds):      How long before the plugin changes the map. 
//
// amx_map_empty(map_name):       This is the map you want to change to if
//                                the server is empty.
//                        Read!-> If you write "amx-nextmap" it will use the
//                                next map in the map cycle.
//
// amx_map_players(map_name):     This is the map you want to change to when
//                                the server is not empty any more.
//                        Read!-> If you write "amx-nextmap" it will use the
//                                next map in the map cycle.
//
// amx_timelimit_empty(minutes):  This is the mp_timelimit you want to have 
//                                if the server is empty.
//                        Read!-> It can NOT be same value as
//                                amx_timelimit_players (under)
//
// amx_timelimit_players(minutes):This is the mp_timelimit you want to have
//                                if the server is not empty any more.
//                        Read!-> It can NOT be same value as
//                                amx_timelimit_empty (above)
//
// amx_idletime(in hours):        How many hours a player can be connected to 
//                                the server before being considered idle.
//
// amx_map_memory(0):             DON'T CHANGE THIS ONE. Plugin uses this to 
//                                get the amx-nextmap to work OK.
//
	register_cvar("amx_staytime","600")
	register_cvar("amx_map_empty","de_dust")
	register_cvar("amx_map_players","amx-nextmap")
	register_cvar("amx_timelimit_empty","0")
	register_cvar("amx_timelimit_players","30")
	register_cvar("amx_idletime","1")
//
	register_cvar("amx_map_memory","0")
        get_cvar_string("amx_map_memory",amx_map_memory,50)
        timelimit_empty = get_cvar_num("amx_timelimit_empty")
        timelimit_players = get_cvar_num("amx_timelimit_players")
        get_cvar_string("amx_map_empty",map_empty,50)
        get_cvar_string("amx_map_players",map_players,50)
//
        if(equal(map_empty,"amx-nextmap")&&equal(amx_map_memory,"0"))
        {
                get_cvar_string("amx_nextmap",map_empty,50)
	}
        if(equal(map_players,"amx-nextmap")&&equal(amx_map_memory,"0"))
        {
                get_cvar_string("amx_nextmap",map_players,50)
	}
        if(equal(map_empty,"amx-nextmap")&&!equal(amx_map_memory,"0"))
        {
                get_cvar_string("amx_map_memory",map_empty,50)
	}
        if(equal(map_players,"amx-nextmap")&&!equal(amx_map_memory,"0"))
        {
                get_cvar_string("amx_map_memory",map_players,50)
	}
//
	staytime = get_cvar_num("amx_staytime")
	set_task(1.0,"timer",0,"curtime",0,"b",1)
}
	
public timer()
{
	if(get_playersnum() == 0)
	{
		curtime ++
		if(curtime >= staytime)
			change_maps_forempty()
	}
	else
	{		
		new players,i,noncounted
		players = get_playersnum()
		for(i=1;i<=get_maxplayers();i++)
		{
			if((get_user_time(i,1) >= (get_cvar_num("amx_idletime") * 216000)) || is_user_bot(i) || is_user_hltv(i))
			{
        if(!is_user_admin(i))
          {
          noncounted++
          }
			}
		}
		if(players == noncounted)
		{
			curtime++
			if(curtime >= staytime)
				change_maps_forempty()
		}
		else
		{
			curtime = 0
			change_maps_forplayer()
		}
	}
	return curtime
}

public change_maps_forempty() 
{ 
    new the_next_map2[51]
    get_cvar_string("amx_nextmap",the_next_map2,50)
    if(timelimit_empty==get_cvar_num("mp_timelimit"))
     { 
  	  curtime = 0
     }	
     else 
     {
          set_cvar_string("amx_map_memory",the_next_map2)
          server_cmd("changelevel %s",map_empty) 
          set_cvar_num("mp_timelimit",timelimit_empty)
     }
    return PLUGIN_HANDLED
}  

public change_maps_forplayer()
{  
    new curmap[51],amx_check_players[51],amx_check_empty[51]
    get_mapname(curmap,50)   
    get_cvar_string("amx_map_empty",amx_check_empty,50)
    get_cvar_string("amx_map_players",amx_check_players,50)  
    if(equal(curmap, map_players)&&timelimit_empty==get_cvar_num("mp_timelimit")) 
     {  
        set_cvar_num("mp_timelimit",timelimit_players)
     }  
    if(!equal(curmap, map_players)&&timelimit_empty==get_cvar_num("mp_timelimit")) 
     {  
        if(!equal(amx_check_empty, amx_check_players))
        {
            server_cmd("changelevel %s",map_players)     
        }
        set_cvar_num("mp_timelimit",timelimit_players)
     }  
    return PLUGIN_HANDLED 
}