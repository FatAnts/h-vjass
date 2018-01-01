/* 单位组 */
globals
hMedia media = 0
endglobals

type MediaDialogue extends string array[10] //电影对白最大支持10句

struct hMedia

	private static real bgmDelay = 2.00

	//播放音效
	public static method soundPlay takes sound s returns nothing
	    if (s != null) then
	        call StartSound(s)
	    endif
	endmethod

	//绑定单位音效
	public static method soundPlay2Unit takes sound s,unit u returns nothing
	    call PlaySoundOnUnitBJ( s, 100, u )
	endmethod

	//绑定点音效
	public static method soundPlay2Loc takes sound s,real x,real y,real z returns nothing
	    call SetSoundPosition( s, x, y, z )
	endmethod

	private static method bgmCall takes nothing returns nothing
		local timer t = GetExpiredTimer()
		call PlayMusic(time.getString(t,1))
		call time.delTimer(t)
	endmethod
	//播放音乐
	public static method bgm takes string musicFileName returns nothing
		local timer t = null
		if(musicFileName!=null and musicFileName!="")then
			call StopMusic( true )
			set t = time.setTimeout(bgmDelay,function thistype.bgmCall)
			call time.setString(t,1,musicFileName)
		endif
	endmethod

	private static method bgm2PlayerCall takes nothing returns nothing
		local timer t = GetExpiredTimer()
		if(GetLocalPlayer() == time.getPlayer(t,2))then
			call PlayMusic(time.getString(t,1))
		endif
		call time.delTimer(t)
	endmethod
	//对玩家播放音乐
	public static method bgm2Player takes string musicFileName,player whichPlayer returns nothing
		local timer t = null
		if(musicFileName!=null and musicFileName!="" and whichPlayer != null)then
			if(GetLocalPlayer() == whichPlayer)then
				call StopMusic( true )
				set t = time.setTimeout(bgmDelay,function thistype.bgm2PlayerCall)
				call time.setString(t,1,musicFileName)
				call time.setPlayer(t,2,whichPlayer)
			endif
		endif
	endmethod




	/**
	 * 对势力播放电影
	 */
	public static method moive2force takes force whichForce,unit speaker,MediaDialogue dia returns nothing
		local integer i = 0
		local real during = 0
		set i = 1
	    loop
	        exitwhen i > 10
	        	if( dia[i] == null or dia[i] == "" ) then
					call DoNothing() YDNL exitwhen true
	        	else
		        	set during = I2R(StringLength(dia[i]))*0.03 + 3.00
	    			call TransmissionFromUnitWithNameBJ( whichForce , speaker , GetUnitName(speaker) , null , dia[i] , bj_TIMETYPE_SET, during , true )
	        	endif
	        set i = i + 1
	    endloop
	endmethod

	/**
	 * 对玩家播放电影
	 */
	public static method moive2Player takes player whichPlayer,unit speaker,MediaDialogue dia returns nothing
		local integer i = 0
		local real during = 0
		set i = 1
	    loop
	        exitwhen i > 10
	        	if( dia[i] == null or dia[i] == "" ) then
					call DoNothing() YDNL exitwhen true
	        	else
		        	set during = I2R(StringLength(dia[i]))*0.03 + 3.00
	    			call TransmissionFromUnitWithNameBJ( bj_FORCE_PLAYER[GetPlayerId(whichPlayer)] , speaker , GetUnitName(speaker) , null , dia[i] , bj_TIMETYPE_SET, during , true )
	        	endif
	        set i = i + 1
	    endloop
	endmethod
	
endstruct
