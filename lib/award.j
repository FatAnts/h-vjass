/** 
 * 奖励
 */

globals
    hAward haward
    real hAwardRange = 2000.00
endglobals

struct hAward

    /**
     * 设置共享范围
     */
    public method setRange takes real range returns nothing
        set hAwardRange = range
    endmethod

    /**
     * 奖励单位（经验黄金木头）
     */
    public method forUnit takes unit whichUnit,integer exp,integer gold,integer lumber returns nothing
        local string floatStr = null
        local integer realExp = exp
        local integer realGold = gold
        local integer realLumber = lumber
        local integer index = 0
        local integer ttgColorLen = 0
        local texttag ttg = null
        local player p = null

        if( whichUnit == null ) then
            return
        endif
        set floatStr = ""
        set index = GetConvertedPlayerId(GetOwningPlayer( whichUnit ))

        // 增益
        set realGold 	= R2I( I2R(gold) * hplayer.getGoldRatio(GetOwningPlayer( whichUnit )) / 100.00 )
        set realLumber	= R2I( I2R(lumber) * hplayer.getLumberRatio(GetOwningPlayer( whichUnit )) / 100.00 )
        set realExp		= R2I( I2R(exp) * hplayer.getExpRatio(GetOwningPlayer( whichUnit )) / 100.00 )
        set p = GetOwningPlayer(whichUnit)
        
        if(realExp >=1 and his.hero(whichUnit)) then
            call AddHeroXPSwapped(realExp,whichUnit,true )
            set floatStr = floatStr + "|cffc4c4ff" + I2S(realExp)+"Exp" + "|r"
            set ttgColorLen = ttgColorLen + 12
        endif
        if(realGold >=1 ) then
            call hplayer.addGold(p,realGold )
            set floatStr = floatStr + " |cffffcc00" + I2S(realGold)+"G" + "|r"
            set ttgColorLen = ttgColorLen + 13
            call hmedia.soundPlay2Unit(gg_snd_ReceiveGold,whichUnit)
        endif
        if(realLumber >=1 ) then
            call hplayer.addLumber(p,realLumber )
            set floatStr = floatStr + " |cff80ff80" + I2S(realLumber)+"L" + "|r"
            set ttgColorLen = ttgColorLen + 13
            call hmedia.soundPlay2Unit(gg_snd_BundleOfLumber,whichUnit)
        endif
        set ttg = hmsg.ttg2Unit(whichUnit,floatStr,7,"",0,1.70,60.00)
        call SetTextTagPos( ttg , GetUnitX(whichUnit)-I2R(StringLength(floatStr)-ttgColorLen)*7*0.5 , GetUnitY(whichUnit) , 50 )
        call hmsg.style(ttg,"toggle",0,0.23)
        set floatStr = null
        set ttg = null
        set p = null
        set whichUnit = null
    endmethod

    /**
     * 奖励单位黄金
     */
    public method forUnitGold takes unit whichUnit,integer gold returns nothing
        call forUnit(whichUnit,0,gold,0)
        set whichUnit = null
    endmethod
    /**
     * 奖励单位木头
     */
    public method forUnitLumber takes unit whichUnit,integer lumber returns nothing
        call forUnit(whichUnit,0,0,lumber)
        set whichUnit = null
    endmethod
    /**
     * 奖励单位经验
     */
    public method forUnitExp takes unit whichUnit,integer exp returns nothing
        call forUnit(whichUnit,exp,0,0)
        set whichUnit = null
    endmethod

    /**
     * 平分奖励英雄组（经验黄金木头）
     */
    public method forGroup takes unit whichUnit,integer exp,integer gold,integer lumber returns nothing
        local unit u = null
        local group g = null
        local integer gCount = 0
        local integer cutExp = 0
        local integer cutGold = 0
        local integer cutLumber = 0
        local hFilter filter = 0
        set filter = hFilter.create()
        call filter.isHero(true)
        call filter.isAlly(true,whichUnit)
        call filter.isAlive(true)
        call filter.isBuilding(false)
        set g = hgroup.createByUnit(whichUnit,hAwardRange,function hFilter.get)
        call filter.destroy()
        set gCount = CountUnitsInGroup( g )
        if( gCount <=0 ) then
            set whichUnit = null
            return
        endif
        set cutExp = R2I(I2R(exp) / I2R(gCount))
        set cutGold = R2I(I2R(gold) / I2R(gCount))
        set cutLumber = R2I(I2R(lumber) / I2R(gCount))
        if(exp > 0 and cutExp<1)then
            set cutExp = 1
        endif
        loop
            exitwhen(IsUnitGroupEmptyBJ(g) == true)
                //must do
                set u = FirstOfGroup(g)
                call GroupRemoveUnit( g , u )
                //
                call forUnit(u,cutExp,cutGold,cutLumber)
                set u = null
        endloop
        call GroupClear(g)
        call DestroyGroup(g)
        set g = null
        set whichUnit = null
    endmethod

    /**
     * 平分奖励玩家组（黄金木头）
     */
    public method forPlayer takes integer gold,integer lumber returns nothing
        local integer i = 0
        local integer cutGold = R2I(I2R(gold) / I2R(player_current_qty))
        local integer cutLumber = R2I(I2R(lumber) / I2R(player_current_qty))
        set i = player_max_qty
        loop
            exitwhen(i<=0)
                if(hplayer.getStatus(players[i])==hplayer.default_status_gaming)then
                    call hplayer.addGold(players[i],cutGold)
                    call hplayer.addLumber(players[i],cutLumber)
                endif
            set i=i-1
        endloop
    endmethod

    /**
     * 平分奖励英雄组黄金
     */
    public method forGroupGold takes unit whichUnit,integer gold returns nothing
        call forGroup(whichUnit,0,gold,0)
        set whichUnit = null
    endmethod
    /**
     * 平分奖励英雄组木头
     */
    public method forGroupLumber takes unit whichUnit,integer lumber returns nothing
        call forGroup(whichUnit,0,0,lumber)
        set whichUnit = null
    endmethod
    /**
     * 平分奖励英雄组经验
     */
    public method forGroupExp takes unit whichUnit,integer exp returns nothing
        call forGroup(whichUnit,exp,0,0)
        set whichUnit = null
    endmethod

    /**
     * 平分奖励玩家组黄金
     */
    public method forPlayerGold takes unit whichUnit,integer gold returns nothing
        call forPlayer(gold,0)
        set whichUnit = null
    endmethod
    /**
     * 平分奖励玩家组木头
     */
    public method forPlayerLumber takes unit whichUnit,integer lumber returns nothing
        call forPlayer(0,lumber)
        set whichUnit = null
    endmethod

endstruct
