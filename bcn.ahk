#SingleInstance, Force
#NoEnv

global startupFilePath := A_Startup "\BatteryChargedNotificationApplication.lnk"

Menu, Tray, NoStandard
Menu, Tray, Click, 1
Menu, Tray, Add, О разработчике, aboutdev
Menu, Tray, Add,
Menu, Tray, Add, Добавить в автозапуск, addToStartup
Menu, Tray, Add,
Menu, Tray, Add, Выход из программы, exitapp
Menu, Tray, Default, О разработчике
Menu, Tray, Tip, Уведомления о полном заряде батареи

if (isInStartup())
  Menu, Tray, Check, Добавить в автозапуск

isInStartup() {
  IfExist, %startupFilePath%
  {
    FileGetShortcut, % startupFilePath, targetFilePath
    if (targetFilePath == A_ScriptFullPath)
      return true
    else
      return false
  }
}

getBatteryInfo() {
  VarSetCapacity(powerstatus, 1+1+1+1+4+4)
  DllCall("kernel32.dll\GetSystemPowerStatus", "uint", &powerstatus)
  
  batteryInfo := []
  batteryInfo["acLineStatus"] := ReadInteger(&powerstatus,0,1,false) ; идет ли зарядка (0/1)
  batteryInfo["flag"] := ReadInteger(&powerstatus,1,1,false) ; уровень заряда батареи
  batteryInfo["percent"] := ReadInteger(&powerstatus,2,1,false) ; процент заряда
  batteryInfo["lifeTime"] := ReadInteger(&powerstatus,4,4,false) ; на сколько секунд хватит заряда батареи (-1 значит неизвестно)
  batteryInfo["fullLifeTime"] := ReadInteger(&powerstatus,8,4,false) ; количество секунд, необходимое для зарядки (-1 значит неизвестно)

  return batteryInfo
}

ReadInteger(p_address, p_offset, p_size, p_hex=true)
{
  value = 0
  old_FormatInteger := a_FormatInteger
  if ( p_hex )
    SetFormat, integer, hex
  else
    SetFormat, integer, dec
  loop, %p_size%
    value := value+( *( ( p_address+p_offset )+( a_Index-1 ) ) << ( 8* ( a_Index-1 ) ) )
  SetFormat, integer, %old_FormatInteger%
  return, value
}

GetFormatedTime(_seconds) {
	local h, m, s, t
	h := _seconds // 3600
	_seconds -= h * 3600
	m := _seconds // 60
	s := _seconds - m * 60

	if (h > 1)
		t := h . " часов"
	else if (h = 1)
		t := "1 час"

	if (t != "" and m + s > 0)
		t := t . " "

	if (m > 1)
		t := t . m . " мин"

	else if (m = 1)
		t := t . "1 мин"

	if (t != "" and s > 0)
		t := t . " "

	if (s > 1)
		t := t . s . " сек"

	else if (s = 1)
		t := t . "1 сек"

	else if (t = "")
		t := "0 сек"

	return t
}

isCharged := true
isInStartup()

while (true) {
  sleep 3000
  batteryInfo := getBatteryInfo()
  if ((batteryInfo["percent"] == 100) && (batteryInfo["acLineStatus"] == 1))
    if (!isCharged)
      TrayTip, Аккумулятор полностью заряжен, Пожалуйста`, отключите зарядное устройство.
  else
    isCharged := false
}

exitapp:
ExitApp

aboutdev:
MsgBox, 36, О программе, Разработано Streleckiy Development.`n`nОткрыть ссылку (http://vk.com/strdev)?
ifMsgBox, Yes
   Run, http://vk.com/strdev

return

addToStartup:
if (isInStartup()) {
  FileDelete, %startupFilePath%
  Menu, Tray, UnCheck, Добавить в автозапуск
} else {
  FileCreateShortcut, %A_ScriptFullPath%, %startupFilePath%
  Menu, Tray, Check, Добавить в автозапуск
}
return