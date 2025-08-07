#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

global crosshair := {top: 0, bottom: 0, left: 0, right: 0}
global outline := {top: 0, bottom: 0, left: 0, right: 0}

global zoomActive := false
global zoomGui := ""
global overlaySize := 350
global currentHotkey := ""
global rightClickToggleState := true

global settings := Map(
    "length", 5,
    "thickness", 2,
    "color", "00FF00",
    "opacity", 10,
    "gap", 5,
    "visible", true,
    "rightClickHide", true,
    "rightClickMode", "hold",
    "outlineEnabled", false,
    "outlineColor", "000000",
    "outlineThickness", 1,
    "lines", Map("top", true, "bottom", true, "left", true, "right", true),
    "profiles", Map(),
    "currentProfile", "",
    "zoomEnabled", true,
    "zoomHotkey", "c",
    "zoomToggleMode", false
)

global colorMap := Map(
    "Green", "00FF00",
    "Red", "FF0000",
    "Blue", "0000FF",
    "White", "FFFFFF",
    "Black", "000000",
    "Yellow", "FFFF00",
    "Cyan", "00FFFF",
    "Magenta", "FF00FF",
    "Orange", "FFA500"
)

global settingsGui := Gui("-Resize", "moris crosshair tool v1.1")
settingsGui.OnEvent("Close", GuiClose)
settingsGui.OnEvent("Escape", GuiClose)

settingsGui.SetFont("s9", "Segoe UI")
settingsGui.MarginX := 10
settingsGui.MarginY := 10

tab := settingsGui.Add("Tab3", "x10 y10 w298 h285", ["Crosshair", "Profiles", "Zoom"])
tab.UseTab(1)

generalGroup := settingsGui.Add("GroupBox", "x16 y40 w140 h250", "General Settings")

settingsGui.Add("Text", "x24 y60 w50 h20", "Length:")
lengthEdit := settingsGui.Add("Edit", "x24 y80 w50 h22 vLengthEdit Number", settings["length"])
lengthUpDown := settingsGui.Add("UpDown", "vLengthUpDown Range1-100", settings["length"])
lengthUpDown.OnEvent("Change", UpdateSettings)

settingsGui.Add("Text", "x24 y110 w50 h20", "Gap:")
gapEdit := settingsGui.Add("Edit", "x24 y130 w50 h22 vGapEdit Number", settings["gap"])
gapUpDown := settingsGui.Add("UpDown", "vGapUpDown Range0-50", settings["gap"])
gapUpDown.OnEvent("Change", UpdateSettings)

settingsGui.Add("Text", "x24 y160 w50 h20", "Color:")
colorDropdown := settingsGui.Add("DropDownList", "x24 y180 w120 h200 vColor Choose1", [
    "Green", "Red", "Blue", "White", "Black", "Yellow", "Cyan", "Magenta", "Orange"
])
colorDropdown.OnEvent("Change", UpdateSettings)

settingsGui.Add("Text", "x94 y60 w60 h20", "Thickness:")
thicknessEdit := settingsGui.Add("Edit", "x94 y80 w50 h22 vThicknessEdit Number", settings["thickness"])
thicknessUpDown := settingsGui.Add("UpDown", "vThicknessUpDown Range1-10", settings["thickness"])
thicknessUpDown.OnEvent("Change", UpdateSettings)

settingsGui.Add("Text", "x94 y110 w60 h20", "Opacity:")
opacityEdit := settingsGui.Add("Edit", "x94 y130 w50 h22 vOpacityEdit Number", settings["opacity"])
opacityUpDown := settingsGui.Add("UpDown", "vOpacityUpDown Range1-10", settings["opacity"])
opacityUpDown.OnEvent("Change", UpdateSettings)

settingsGui.Add("Text", "x24 y210", "Crosshair Line Visibility:")
topCB := settingsGui.Add("CheckBox", "x80 y230 w20 h20 vTopCB Checked" (settings["lines"]["top"] ? 1 : 0))
bottomCB := settingsGui.Add("CheckBox", "x80 y266 w20 h20 vBottomCB Checked" (settings["lines"]["bottom"] ? 1 : 0))
leftCB := settingsGui.Add("CheckBox", "x60 y248 w20 h20 vLeftCB Checked" (settings["lines"]["left"] ? 1 : 0))
rightCB := settingsGui.Add("CheckBox", "x100 y248 w20 h20 vRightCB Checked" (settings["lines"]["right"] ? 1 : 0))

topCB.OnEvent("Click", UpdateLineVisibility)
bottomCB.OnEvent("Click", UpdateLineVisibility)
leftCB.OnEvent("Click", UpdateLineVisibility)
rightCB.OnEvent("Click", UpdateLineVisibility)

outlineGroup := settingsGui.Add("GroupBox", "x164 y40 w136 h130", "Outline Settings")

outlineEnabledCB := settingsGui.Add("CheckBox", "x172 y70 w120 h20 vOutlineEnabledCB Checked" (settings["outlineEnabled"] ? 1 : 0), "Enable Outline")
outlineEnabledCB.OnEvent("Click", UpdateOutlineSettings)

settingsGui.Add("Text", "x172 y100", "Color:")
outlineColorDropdown := settingsGui.Add("DropDownList", "x172 y120 w50 h200 vOutlineColor Choose1", [
    "Black", "White", "Red", "Blue", "Green", "Yellow", "Cyan", "Magenta", "Orange"
])
outlineColorDropdown.OnEvent("Change", UpdateOutlineSettings)

settingsGui.Add("Text", "x242 y100", "Thickness:")
outlineThicknessEdit := settingsGui.Add("Edit", "x242 y120 w50 h22 vOutlineThicknessEdit Number", settings["outlineThickness"])
outlineThicknessUpDown := settingsGui.Add("UpDown", "vOutlineThicknessUpDown Range1-5", settings["outlineThickness"])
outlineThicknessUpDown.OnEvent("Change", UpdateOutlineSettings)

otherGroup := settingsGui.Add("GroupBox", "x164 y172 w136 h118", "Other")

rightClickToggleCB := settingsGui.Add("CheckBox", "x172 y193 w120 h20 vRightClickToggleCB Checked" (settings["rightClickHide"] ? 1 : 0), "Right Click Hide")
rightClickToggleCB.OnEvent("Click", UpdateRightClickSetting)

settingsGui.Add("Text", "x173 y224 ", "Mode:")
rightClickModeDropdown := settingsGui.Add("DropDownList", "x220 y221 w71 vRightClickMode Choose" (settings["rightClickMode"] = "hold" ? "1" : "2"), ["Hold", "Toggle"])
rightClickModeDropdown.OnEvent("Change", UpdateRightClickMode)

hideBtn := settingsGui.Add("Button", "x172 y255 w120 h24", settings["visible"] ? "Hide Crosshair" : "Show Crosshair")
hideBtn.OnEvent("Click", ToggleCrosshairVisibility)

tab.UseTab(2)

profileList := settingsGui.Add("ListBox", "x16 y40 w284 h172 vProfileList")
profileList.OnEvent("Change", (*) => profileNameEdit.Value := profileList.Text)

settingsGui.Add("Text", "x18 y220 w40 h20", "Name:")
profileNameEdit := settingsGui.Add("Edit", "x60 y218 w240 h22 vProfileName", "New Profile")

settingsGui.Add("Button", "x16 y248 w90 h40", "Save").OnEvent("Click", SaveProfile)
settingsGui.Add("Button", "x113 y248 w90 h40", "Load").OnEvent("Click", LoadProfile)
settingsGui.Add("Button", "x210 y248 w90 h40", "Delete").OnEvent("Click", DeleteProfile)

tab.UseTab(3)

zoomGroup := settingsGui.Add("GroupBox", "x16 y40 w284 h245", "Zoom Settings")

zoomEnabledCB := settingsGui.Add("CheckBox", "x24 y60 vZoomEnabledCB Checked" (settings["zoomEnabled"] ? 1 : 0), "Enable Zoom on Key")
zoomEnabledCB.OnEvent("Click", UpdateZoomSettings)

settingsGui.Add("Text", "x24 y90 w80 h20", "Zoom Hotkey:")
zoomHotkeyEdit := settingsGui.Add("Edit", "x24 y110 w100 h22 vZoomHotkeyEdit Uppercase Limit1", settings["zoomHotkey"])
zoomHotkeyEdit.OnEvent("Change", UpdateZoomHotkey)

settingsGui.Add("Text", "x24 y140 w80 h20", "Zoom Mode:")
zoomModeDropdown := settingsGui.Add("DropDownList", "x24 y160 w120 h200 vZoomMode Choose" (settings["zoomToggleMode"] ? "2" : "1"), ["Hold", "Toggle"])
zoomModeDropdown.OnEvent("Change", UpdateZoomToggleMode)

tab.UseTab()

LoadSettings()
CreateCrosshair()
CenterCrosshair()
SetupZoomHotkey()
settingsGui.Show("w316 h304")
SetTimer(CheckResolution, 1000)

*~RButton::
{
    global
    if (!settings["rightClickHide"])
        return
        
    if GetKeyState("RButton", "P") {
        if (settings["rightClickMode"] = "hold") {
            HideCrosshair()
            KeyWait("RButton")
            if (settings["visible"]) {
                ShowCrosshair()
            }
        } else {
            rightClickToggleState := !rightClickToggleState
            if (rightClickToggleState && settings["visible"]) {
                ShowCrosshair()
            } else {
                HideCrosshair()
            }
            KeyWait("RButton")
        }
    }
}

SetupZoomHotkey() {
    global
    if (currentHotkey != "") {
        try {
            Hotkey(currentHotkey, "Off")
        }
        try {
            Hotkey(currentHotkey " up", "Off")
        }
    }
    
    if (settings["zoomEnabled"] && settings["zoomHotkey"] != "") {
        try {
            currentHotkey := "~*" . settings["zoomHotkey"]
            if (settings["zoomToggleMode"]) {
                Hotkey(currentHotkey, ZoomToggle, "On")
            } else {
                Hotkey(currentHotkey, ZoomStart, "On")
                Hotkey(currentHotkey " up", ZoomStop, "On")
            }
        } catch Error as e {
            MsgBox("Invalid hotkey: " settings["zoomHotkey"] ". Error: " e.Message, "Error", "Icon!")
        }
    }
}

ZoomToggle(*) {
    global
    if (!settings["zoomEnabled"])
        return
    
    if (zoomActive) {
        zoomActive := false
        StopZoom()
        SetTimer(UpdateZoom, 0)
    } else {
        zoomActive := true
        StartZoom()
        SetTimer(UpdateZoom, 17)
    }
}

ZoomStart(*) {
    global
    if (!settings["zoomEnabled"] || zoomActive)
        return
    
    zoomActive := true
    StartZoom()
    SetTimer(UpdateZoom, 17)
}

ZoomStop(*) {
    global
    if (!zoomActive)
        return
        
    zoomActive := false
    StopZoom()
    SetTimer(UpdateZoom, 0)
}

StartZoom() {
    global
    
    captureSize := Round(overlaySize / 3.0)
    
    centerX := A_ScreenWidth // 2
    centerY := A_ScreenHeight // 2
    
    overlayX := centerX - (overlaySize // 2)
    overlayY := centerY + (captureSize // 2) + 20

    if (overlayX < 0) {
        overlayX := 10
    }
    if (overlayX + overlaySize > A_ScreenWidth) {
        overlayX := A_ScreenWidth - overlaySize - 10
    }
    if (overlayY + overlaySize > A_ScreenHeight) {
        overlayY := A_ScreenHeight - overlaySize - 10
    }

    zoomGui := Gui("+AlwaysOnTop +ToolWindow -Caption", "ZoomOverlay")
    zoomGui.MarginX := 0
    zoomGui.MarginY := 0

    zoomGui.Add("Picture", "x0 y0 w" . overlaySize . " h" . overlaySize . " vZoomPic")

    centerX := A_ScreenWidth // 2
    centerY := A_ScreenHeight // 2
    captureX := centerX - (captureSize // 2)
    captureY := centerY - (captureSize // 2)
    
    tempFile := A_Temp . "\zoom_" . A_TickCount . ".bmp"
    result := CaptureScreenArea(captureX, captureY, captureSize, tempFile)
    
    if (result && FileExist(tempFile)) {
        zoomGui["ZoomPic"].Value := tempFile
    }

    zoomGui.Show("x" . overlayX . " y" . overlayY . " w" . overlaySize . " h" . overlaySize . " NoActivate")
    WinSetExStyle("+0x20", zoomGui.Hwnd)
}

StopZoom() {
    global
    if (zoomGui) {
        zoomGui.Destroy()
        zoomGui := ""
    }
    try {
        Loop Files, A_Temp . "\zoom_*.bmp"
            FileDelete(A_LoopFileFullPath)
    }
}

UpdateZoom() {
    global
    if (!zoomActive || !zoomGui) {
        return
    }
    
    try {
        captureSize := Round(overlaySize / 3.0)
        
        centerX := A_ScreenWidth // 2
        centerY := A_ScreenHeight // 2
        captureX := centerX - (captureSize // 2)
        captureY := centerY - (captureSize // 2)

        tempFile := A_Temp . "\zoom_" . A_TickCount . ".bmp"
        result := CaptureScreenArea(captureX, captureY, captureSize, tempFile)
        
        if (result && FileExist(tempFile)) {
            try {
                zoomGui["ZoomPic"].Value := tempFile
                SetTimer(() => CleanupFile(tempFile), -2000)
            } catch {
            }
        }
    } catch {
    }
}

CaptureScreenArea(x, y, size, outputFile) {
    try {
        hdc := DllCall("GetDC", "Ptr", 0, "Ptr")
        hCDC := DllCall("CreateCompatibleDC", "Ptr", hdc, "Ptr")
        hBmp := DllCall("CreateCompatibleBitmap", "Ptr", hdc, "Int", size, "Int", size, "Ptr")
        DllCall("SelectObject", "Ptr", hCDC, "Ptr", hBmp)

        DllCall("BitBlt", "Ptr", hCDC, "Int", 0, "Int", 0, "Int", size, "Int", size,
                "Ptr", hdc, "Int", x, "Int", y, "UInt", 0x00CC0020)

        SaveBitmapToFile(hBmp, outputFile, size)

        DllCall("DeleteObject", "Ptr", hBmp)
        DllCall("DeleteDC", "Ptr", hCDC)
        DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc)
        
        return true
    } catch {
        return false
    }
}

SaveBitmapToFile(hBmp, filepath, size) {
    try {
        hdc := DllCall("GetDC", "Ptr", 0, "Ptr")

        fileHeader := Buffer(14, 0)
        NumPut("UShort", 0x4D42, fileHeader, 0)
        NumPut("UInt", 54 + (size * size * 3), fileHeader, 2)
        NumPut("UInt", 54, fileHeader, 10)

        infoHeader := Buffer(40, 0)
        NumPut("UInt", 40, infoHeader, 0)
        NumPut("Int", size, infoHeader, 4)
        NumPut("Int", -size, infoHeader, 8)
        NumPut("UShort", 1, infoHeader, 12)
        NumPut("UShort", 24, infoHeader, 14)

        stride := ((size * 3 + 3) // 4) * 4
        pixelData := Buffer(stride * size, 0)
        DllCall("GetDIBits", "Ptr", hdc, "Ptr", hBmp, "UInt", 0, "UInt", size,
                "Ptr", pixelData.ptr, "Ptr", infoHeader.ptr, "UInt", 0)

        file := FileOpen(filepath, "w")
        if (file) {
            file.RawWrite(fileHeader)
            file.RawWrite(infoHeader)
            file.RawWrite(pixelData)
            file.Close()
        }
        
        DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc)
        return true
    } catch {
        return false
    }
}

CleanupFile(keepFile) {
    try {
        Loop Files, A_Temp . "\zoom_*.bmp" {
            if (A_LoopFileFullPath != keepFile) {
                FileDelete(A_LoopFileFullPath)
            }
        }
    }
}

GetColorNameByHex(hexCode) {
    for colorName, hex in colorMap.OwnProps() {
        if (hex = hexCode) {
            return colorName
        }
    }
    return "Green"
}

CreateCrosshair() {
    settings["opacity"] := Max(1, Min(10, settings["opacity"]))
    
    outline.top := Gui("+ToolWindow -Caption +AlwaysOnTop +E0x20")
    outline.top.BackColor := settings["outlineColor"]
    outline.top.Show("NA x0 y0 w1 h1")
    WinSetTransparent(Round(settings["opacity"] * 25.5), outline.top)
    
    outline.bottom := Gui("+ToolWindow -Caption +AlwaysOnTop +E0x20")
    outline.bottom.BackColor := settings["outlineColor"]
    outline.bottom.Show("NA x0 y0 w1 h1")
    WinSetTransparent(Round(settings["opacity"] * 25.5), outline.bottom)
    
    outline.left := Gui("+ToolWindow -Caption +AlwaysOnTop +E0x20")
    outline.left.BackColor := settings["outlineColor"]
    outline.left.Show("NA x0 y0 w1 h1")
    WinSetTransparent(Round(settings["opacity"] * 25.5), outline.left)
    
    outline.right := Gui("+ToolWindow -Caption +AlwaysOnTop +E0x20")
    outline.right.BackColor := settings["outlineColor"]
    outline.right.Show("NA x0 y0 w1 h1")
    WinSetTransparent(Round(settings["opacity"] * 25.5), outline.right)

    crosshair.top := Gui("+ToolWindow -Caption +AlwaysOnTop +E0x20")
    crosshair.top.BackColor := settings["color"]
    crosshair.top.Show("NA x0 y0 w" settings["thickness"] " h" settings["length"])
    WinSetTransparent(Round(settings["opacity"] * 25.5), crosshair.top)
    
    crosshair.bottom := Gui("+ToolWindow -Caption +AlwaysOnTop +E0x20")
    crosshair.bottom.BackColor := settings["color"]
    crosshair.bottom.Show("NA x0 y0 w" settings["thickness"] " h" settings["length"])
    WinSetTransparent(Round(settings["opacity"] * 25.5), crosshair.bottom)
    
    crosshair.left := Gui("+ToolWindow -Caption +AlwaysOnTop +E0x20")
    crosshair.left.BackColor := settings["color"]
    crosshair.left.Show("NA x0 y0 w" settings["length"] " h" settings["thickness"])
    WinSetTransparent(Round(settings["opacity"] * 25.5), crosshair.left)
    
    crosshair.right := Gui("+ToolWindow -Caption +AlwaysOnTop +E0x20")
    crosshair.right.BackColor := settings["color"]
    crosshair.right.Show("NA x0 y0 w" settings["length"] " h" settings["thickness"])
    WinSetTransparent(Round(settings["opacity"] * 25.5), crosshair.right)
    
    if (!settings["visible"]) {
        HideCrosshair()
    }
    UpdateLineVisibility()
}

UpdateCrosshair() {
    if (!settings["visible"])
        return
    
    settings["opacity"] := Max(1, Min(10, settings["opacity"]))
        
    centerX := A_ScreenWidth // 2
    centerY := A_ScreenHeight // 2
    length := settings["length"]
    thickness := settings["thickness"]
    gap := settings["gap"]
    outlineThickness := settings["outlineThickness"]

    topX := centerX - (thickness // 2)
    topY := centerY - length - (gap // 2)
    
    bottomX := centerX - (thickness // 2)
    bottomY := centerY + (gap // 2)
    
    leftX := centerX - length - (gap // 2)
    leftY := centerY - (thickness // 2)
    
    rightX := centerX + (gap // 2)
    rightY := centerY - (thickness // 2)

    outlineTopX := topX - outlineThickness
    outlineTopY := topY - outlineThickness
    outlineTopW := thickness + (outlineThickness * 2)
    outlineTopH := length + (outlineThickness * 2)

    outlineBottomX := bottomX - outlineThickness
    outlineBottomY := bottomY - outlineThickness
    outlineBottomW := thickness + (outlineThickness * 2)
    outlineBottomH := length + (outlineThickness * 2)

    outlineLeftX := leftX - outlineThickness
    outlineLeftY := leftY - outlineThickness
    outlineLeftW := length + (outlineThickness * 2)
    outlineLeftH := thickness + (outlineThickness * 2)

    outlineRightX := rightX - outlineThickness
    outlineRightY := rightY - outlineThickness
    outlineRightW := length + (outlineThickness * 2)
    outlineRightH := thickness + (outlineThickness * 2)

    if (settings["outlineEnabled"]) {
        outline.top.BackColor := settings["outlineColor"]
        if (settings["lines"]["top"]) {
            outline.top.Show("NA x" outlineTopX " y" outlineTopY " w" outlineTopW " h" outlineTopH)
        } else {
            outline.top.Hide()
        }
        WinSetTransparent(Round(settings["opacity"] * 25.5), outline.top)

        outline.bottom.BackColor := settings["outlineColor"]
        if (settings["lines"]["bottom"]) {
            outline.bottom.Show("NA x" outlineBottomX " y" outlineBottomY " w" outlineBottomW " h" outlineBottomH)
        } else {
            outline.bottom.Hide()
        }
        WinSetTransparent(Round(settings["opacity"] * 25.5), outline.bottom)

        outline.left.BackColor := settings["outlineColor"]
        if (settings["lines"]["left"]) {
            outline.left.Show("NA x" outlineLeftX " y" outlineLeftY " w" outlineLeftW " h" outlineLeftH)
        } else {
            outline.left.Hide()
        }
        WinSetTransparent(Round(settings["opacity"] * 25.5), outline.left)

        outline.right.BackColor := settings["outlineColor"]
        if (settings["lines"]["right"]) {
            outline.right.Show("NA x" outlineRightX " y" outlineRightY " w" outlineRightW " h" outlineRightH)
        } else {
            outline.right.Hide()
        }
        WinSetTransparent(Round(settings["opacity"] * 25.5), outline.right)
    } else {
        outline.top.Hide()
        outline.bottom.Hide()
        outline.left.Hide()
        outline.right.Hide()
    }

    crosshair.top.BackColor := settings["color"]
    if (settings["lines"]["top"]) {
        crosshair.top.Show("NA x" topX " y" topY " w" thickness " h" length)
    } else {
        crosshair.top.Hide()
    }
    WinSetTransparent(Round(settings["opacity"] * 25.5), crosshair.top)

    crosshair.bottom.BackColor := settings["color"]
    if (settings["lines"]["bottom"]) {
        crosshair.bottom.Show("NA x" bottomX " y" bottomY " w" thickness " h" length)
    } else {
        crosshair.bottom.Hide()
    }
    WinSetTransparent(Round(settings["opacity"] * 25.5), crosshair.bottom)

    crosshair.left.BackColor := settings["color"]
    if (settings["lines"]["left"]) {
        crosshair.left.Show("NA x" leftX " y" leftY " w" length " h" thickness)
    } else {
        crosshair.left.Hide()
    }
    WinSetTransparent(Round(settings["opacity"] * 25.5), crosshair.left)

    crosshair.right.BackColor := settings["color"]
    if (settings["lines"]["right"]) {
        crosshair.right.Show("NA x" rightX " y" rightY " w" length " h" thickness)
    } else {
        crosshair.right.Hide()
    }
    WinSetTransparent(Round(settings["opacity"] * 25.5), crosshair.right)
}

CenterCrosshair() {
    UpdateCrosshair()
}

UpdateSettings(*) {
    settings["length"] := lengthUpDown.Value
    settings["thickness"] := thicknessUpDown.Value
    settings["gap"] := gapUpDown.Value
    settings["opacity"] := opacityUpDown.Value

    colorName := colorDropdown.Text
    if (colorMap.Has(colorName)) {
        settings["color"] := colorMap[colorName]
    }

    if (settings["currentProfile"] != "") {
        profileName := settings["currentProfile"]
        settings["profiles"][profileName]["length"] := settings["length"]
        settings["profiles"][profileName]["thickness"] := settings["thickness"]
        settings["profiles"][profileName]["gap"] := settings["gap"]
        settings["profiles"][profileName]["color"] := settings["color"]
        settings["profiles"][profileName]["opacity"] := settings["opacity"]
    }

    UpdateCrosshair()
    SaveSettings()
}

UpdateOutlineSettings(*) {
    settings["outlineEnabled"] := outlineEnabledCB.Value
    settings["outlineThickness"] := outlineThicknessUpDown.Value

    colorName := outlineColorDropdown.Text
    if (colorMap.Has(colorName)) {
        settings["outlineColor"] := colorMap[colorName]
    }

    if (settings["currentProfile"] != "") {
        profileName := settings["currentProfile"]
        settings["profiles"][profileName]["outlineEnabled"] := settings["outlineEnabled"]
        settings["profiles"][profileName]["outlineColor"] := settings["outlineColor"]
        settings["profiles"][profileName]["outlineThickness"] := settings["outlineThickness"]
    }

    UpdateCrosshair()
    SaveSettings()
}

UpdateLineVisibility(*) {
    settings["lines"]["top"] := topCB.Value
    settings["lines"]["bottom"] := bottomCB.Value
    settings["lines"]["left"] := leftCB.Value
    settings["lines"]["right"] := rightCB.Value
    
    if (settings["currentProfile"] != "") {
        profileName := settings["currentProfile"]
        settings["profiles"][profileName]["lines"]["top"] := settings["lines"]["top"]
        settings["profiles"][profileName]["lines"]["bottom"] := settings["lines"]["bottom"]
        settings["profiles"][profileName]["lines"]["left"] := settings["lines"]["left"]
        settings["profiles"][profileName]["lines"]["right"] := settings["lines"]["right"]
    }

    UpdateCrosshair()
    SaveSettings()
}

UpdateRightClickSetting(*) {
    settings["rightClickHide"] := rightClickToggleCB.Value

    rightClickToggleState := true
    
    if (settings["currentProfile"] != "") {
        profileName := settings["currentProfile"]
        settings["profiles"][profileName]["rightClickHide"] := settings["rightClickHide"]
    }
    
    SaveSettings()
}

UpdateRightClickMode(*) {
    settings["rightClickMode"] := (rightClickModeDropdown.Value = 1) ? "hold" : "toggle"

    rightClickToggleState := true
    if (!settings["visible"]) {
        ShowCrosshair()
        settings["visible"] := true
        hideBtn.Text := "Hide Crosshair"
    }
    
    if (settings["currentProfile"] != "") {
        profileName := settings["currentProfile"]
        settings["profiles"][profileName]["rightClickMode"] := settings["rightClickMode"]
    }
    
    SaveSettings()
}

UpdateZoomSettings(*) {
    settings["zoomEnabled"] := zoomEnabledCB.Value
    SetupZoomHotkey()
    
    if (settings["currentProfile"] != "") {
        profileName := settings["currentProfile"]
        settings["profiles"][profileName]["zoomEnabled"] := settings["zoomEnabled"]
    }
    
    SaveSettings()
}

UpdateZoomToggleMode(*) {
    global
    oldToggleMode := settings["zoomToggleMode"]
    settings["zoomToggleMode"] := (zoomModeDropdown.Value = 2)
    
    if (zoomActive && oldToggleMode != settings["zoomToggleMode"]) {
        zoomActive := false
        StopZoom()
        SetTimer(UpdateZoom, 0)
    }
    
    SetupZoomHotkey()
    
    if (settings["currentProfile"] != "") {
        profileName := settings["currentProfile"]
        settings["profiles"][profileName]["zoomToggleMode"] := settings["zoomToggleMode"]
    }
    
    SaveSettings()
}

UpdateZoomHotkey(*) {
    newHotkey := zoomHotkeyEdit.Text
    if (newHotkey != "" && RegExMatch(newHotkey, "^[a-zA-Z]$")) {
        settings["zoomHotkey"] := newHotkey
        SetupZoomHotkey()
        
        if (settings["currentProfile"] != "") {
            profileName := settings["currentProfile"]
            settings["profiles"][profileName]["zoomHotkey"] := settings["zoomHotkey"]
        }
        
        SaveSettings()
    }
}

ToggleCrosshairVisibility(*) {
    settings["visible"] := !settings["visible"]
    hideBtn.Text := settings["visible"] ? "Hide Crosshair" : "Show Crosshair"

    rightClickToggleState := true
    
    if (settings["currentProfile"] != "") {
        profileName := settings["currentProfile"]
        settings["profiles"][profileName]["visible"] := settings["visible"]
    }

    if (settings["visible"]) {
        ShowCrosshair()
    } else {
        HideCrosshair()
    }
    SaveSettings()
}

HideCrosshair() {
    for part, gui in crosshair.OwnProps() {
        try gui.Hide()
    }
    for part, gui in outline.OwnProps() {
        try gui.Hide()
    }
}

ShowCrosshair() {
    UpdateCrosshair()
}

CheckResolution() {
    static lastWidth := 0, lastHeight := 0
    width := A_ScreenWidth
    height := A_ScreenHeight
    
    if (width != lastWidth || height != lastHeight) {
        lastWidth := width
        lastHeight := height
        CenterCrosshair()
    }
}

SaveProfile(*) {
    profileName := profileNameEdit.Value
    if (profileName = "") {
        MsgBox("Please enter a profile name", "Error", "Icon!")
        return
    }
    
    profileName := RegExReplace(profileName, '[\\/:*?"<>|]', "_")
    profileFileName := profileName . ".ini"

    IniWrite(settings["length"], profileFileName, "Crosshair", "Length")
    IniWrite(settings["thickness"], profileFileName, "Crosshair", "Thickness")
    IniWrite(settings["gap"], profileFileName, "Crosshair", "Gap")
    IniWrite(settings["color"], profileFileName, "Crosshair", "Color")
    IniWrite(settings["opacity"], profileFileName, "Crosshair", "Opacity")
    IniWrite(settings["visible"], profileFileName, "Crosshair", "Visible")
    IniWrite(settings["rightClickHide"], profileFileName, "Crosshair", "RightClickHide")
    IniWrite(settings["rightClickMode"], profileFileName, "Crosshair", "RightClickMode")
    IniWrite(settings["outlineEnabled"], profileFileName, "Crosshair", "OutlineEnabled")
    IniWrite(settings["outlineColor"], profileFileName, "Crosshair", "OutlineColor")
    IniWrite(settings["outlineThickness"], profileFileName, "Crosshair", "OutlineThickness")
    
    IniWrite(settings["zoomEnabled"], profileFileName, "Zoom", "Enabled")
    IniWrite(settings["zoomHotkey"], profileFileName, "Zoom", "Hotkey")
    IniWrite(settings["zoomToggleMode"], profileFileName, "Zoom", "ToggleMode")

    IniWrite(settings["lines"]["top"], profileFileName, "Lines", "Top")
    IniWrite(settings["lines"]["bottom"], profileFileName, "Lines", "Bottom")
    IniWrite(settings["lines"]["left"], profileFileName, "Lines", "Left")
    IniWrite(settings["lines"]["right"], profileFileName, "Lines", "Right")

    profileSettings := Map(
        "length", settings["length"],
        "thickness", settings["thickness"],
        "color", settings["color"],
        "opacity", settings["opacity"],
        "gap", settings["gap"],
        "visible", settings["visible"],
        "rightClickHide", settings["rightClickHide"],
        "rightClickMode", settings["rightClickMode"],
        "outlineEnabled", settings["outlineEnabled"],
        "outlineColor", settings["outlineColor"],
        "outlineThickness", settings["outlineThickness"],
        "zoomEnabled", settings["zoomEnabled"],
        "zoomHotkey", settings["zoomHotkey"],
        "zoomToggleMode", settings["zoomToggleMode"],
        "lines", Map(
            "top", settings["lines"]["top"],
            "bottom", settings["lines"]["bottom"],
            "left", settings["lines"]["left"],
            "right", settings["lines"]["right"]
        )
    )
    
    settings["profiles"][profileName] := profileSettings

    currentItems := []
    if (profileList.Text != "") {
        currentItems := StrSplit(profileList.Text, "`n")
    }
    
    if (!IsInArray(currentItems, profileName)) {
        profileList.Add([profileName])
    }
    
    settings["currentProfile"] := profileName
    
    SaveProfileList()
}

LoadProfile(*) {
    profileName := profileNameEdit.Value
    if (profileName = "") {
        MsgBox("Please select a profile to load", "Error", "Icon!")
        return
    }
    
    cleanProfileName := RegExReplace(profileName, '[\\/:*?"<>|]', "_")
    profileFileName := cleanProfileName . ".ini"
    
    if (!FileExist(profileFileName)) {
        MsgBox("Profile file '" profileFileName "' not found", "Error", "Icon!")
        return
    }
    
    try {
        settings["length"] := IniRead(profileFileName, "Crosshair", "Length", settings["length"])
        settings["thickness"] := IniRead(profileFileName, "Crosshair", "Thickness", settings["thickness"])
        settings["gap"] := IniRead(profileFileName, "Crosshair", "Gap", settings["gap"])
        settings["color"] := IniRead(profileFileName, "Crosshair", "Color", settings["color"])
        settings["opacity"] := Max(1, Min(10, IniRead(profileFileName, "Crosshair", "Opacity", settings["opacity"])))
        settings["visible"] := IniRead(profileFileName, "Crosshair", "Visible", settings["visible"])
        settings["rightClickHide"] := IniRead(profileFileName, "Crosshair", "RightClickHide", settings["rightClickHide"])
        settings["rightClickMode"] := IniRead(profileFileName, "Crosshair", "RightClickMode", settings["rightClickMode"])
        settings["outlineEnabled"] := IniRead(profileFileName, "Crosshair", "OutlineEnabled", settings["outlineEnabled"])
        settings["outlineColor"] := IniRead(profileFileName, "Crosshair", "OutlineColor", settings["outlineColor"])
        settings["outlineThickness"] := IniRead(profileFileName, "Crosshair", "OutlineThickness", settings["outlineThickness"])
        
        settings["zoomEnabled"] := IniRead(profileFileName, "Zoom", "Enabled", settings["zoomEnabled"])
        settings["zoomHotkey"] := IniRead(profileFileName, "Zoom", "Hotkey", settings["zoomHotkey"])
        settings["zoomToggleMode"] := IniRead(profileFileName, "Zoom", "ToggleMode", settings["zoomToggleMode"])

        settings["lines"]["top"] := IniRead(profileFileName, "Lines", "Top", settings["lines"]["top"])
        settings["lines"]["bottom"] := IniRead(profileFileName, "Lines", "Bottom", settings["lines"]["bottom"])
        settings["lines"]["left"] := IniRead(profileFileName, "Lines", "Left", settings["lines"]["left"])
        settings["lines"]["right"] := IniRead(profileFileName, "Lines", "Right", settings["lines"]["right"])

        lengthUpDown.Value := settings["length"]
        thicknessUpDown.Value := settings["thickness"]
        gapUpDown.Value := settings["gap"]
        opacityUpDown.Value := settings["opacity"]
        outlineThicknessUpDown.Value := settings["outlineThickness"]

        colorName := GetColorNameByHex(settings["color"])
        items := ["Green", "Red", "Blue", "White", "Black", "Yellow", "Cyan", "Magenta", "Orange"]
        loop items.Length {
            if (items[A_Index] = colorName) {
                colorDropdown.Value := A_Index
                break
            }
        }

        outlineColorName := GetColorNameByHex(settings["outlineColor"])
        outlineItems := ["Black", "White", "Red", "Blue", "Green", "Yellow", "Cyan", "Magenta", "Orange"]
        loop outlineItems.Length {
            if (outlineItems[A_Index] = outlineColorName) {
                outlineColorDropdown.Value := A_Index
                break
            }
        }

        topCB.Value := settings["lines"]["top"] ? 1 : 0
        bottomCB.Value := settings["lines"]["bottom"] ? 1 : 0
        leftCB.Value := settings["lines"]["left"] ? 1 : 0
        rightCB.Value := settings["lines"]["right"] ? 1 : 0
        rightClickToggleCB.Value := settings["rightClickHide"] ? 1 : 0
        outlineEnabledCB.Value := settings["outlineEnabled"] ? 1 : 0
        rightClickModeDropdown.Value := (settings["rightClickMode"] = "hold") ? 1 : 2
        
        zoomEnabledCB.Value := settings["zoomEnabled"] ? 1 : 0
        zoomHotkeyEdit.Value := settings["zoomHotkey"]
        zoomModeDropdown.Value := settings["zoomToggleMode"] ? 2 : 1

        hideBtn.Text := settings["visible"] ? "Hide Crosshair" : "Show Crosshair"

        rightClickToggleState := true
        
        settings["currentProfile"] := profileName
        SetupZoomHotkey()
        UpdateCrosshair()
        
    } catch Error as e {
        MsgBox("Error loading profile: " e.Message, "Error", "Icon!")
    }
}

DeleteProfile(*) {
    profileName := profileNameEdit.Value
    if (profileName = "") {
        MsgBox("Please select a profile to delete", "Error", "Icon!")
        return
    }
    
    cleanProfileName := RegExReplace(profileName, '[\\/:*?"<>|]', "_")
    profileFileName := cleanProfileName . ".ini"
    
    if (!FileExist(profileFileName)) {
        MsgBox("Profile file '" profileFileName "' not found", "Error", "Icon!")
        return
    }
    
    if (MsgBox("Are you sure you want to delete profile '" profileName "'?`nThis will delete the file '" profileFileName "'", "Confirm Delete", "YesNo Icon?") = "Yes") {
        try {
            FileDelete(profileFileName)
            
            if (settings["profiles"].Has(profileName)) {
                settings["profiles"].Delete(profileName)
            }

            profileList.Delete()
            for remainingProfileName, _ in settings["profiles"] {
                profileList.Add([remainingProfileName])
            }
            
            profileNameEdit.Value := ""
            if (settings["currentProfile"] = profileName) {
                settings["currentProfile"] := ""
            }
            
            SaveProfileList()
            
        } catch Error as e {
            MsgBox("Error deleting profile: " e.Message, "Error", "Icon!")
        }
    }
}

SaveProfileList() {
    profileNames := ""
    for profileName, _ in settings["profiles"] {
        profileNames .= (profileNames != "" ? "|" : "") profileName
    }
    IniWrite(profileNames, "currentsettings.ini", "Profiles", "Names")
}

LoadProfilesFromFiles() {
    profileList.Delete()

    profileNames := IniRead("currentsettings.ini", "Profiles", "Names", "")
    loadedProfiles := Map()
    
    if (profileNames != "") {
        profileNames := StrSplit(profileNames, "|")
        for profileName in profileNames {
            if (profileName = "")
                continue
            
            cleanProfileName := RegExReplace(profileName, '[\\/:*?"<>|]', "_")
            profileFileName := cleanProfileName . ".ini"
            
            if (FileExist(profileFileName)) {
                if (LoadSingleProfile(profileName, profileFileName)) {
                    loadedProfiles[profileName] := true
                }
            }
        }
    }

    Loop Files, "*.ini" {
        if (A_LoopFileName = "currentsettings.ini" || A_LoopFileName = "settings.ini")
            continue

        profileName := RegExReplace(A_LoopFileName, "\.ini$", "")

        if (loadedProfiles.Has(profileName))
            continue

        if (LoadSingleProfile(profileName, A_LoopFileName)) {
            loadedProfiles[profileName] := true
        }
    }

    SaveProfileList()
}

LoadSingleProfile(profileName, profileFileName) {
    try {
        testRead := IniRead(profileFileName, "Crosshair", "Length", "NOTFOUND")
        if (testRead = "NOTFOUND")
            return false
            
        profileSettings := Map()
        profileSettings["length"] := IniRead(profileFileName, "Crosshair", "Length", settings["length"])
        profileSettings["thickness"] := IniRead(profileFileName, "Crosshair", "Thickness", settings["thickness"])
        profileSettings["gap"] := IniRead(profileFileName, "Crosshair", "Gap", settings["gap"])
        profileSettings["color"] := IniRead(profileFileName, "Crosshair", "Color", settings["color"])
        profileSettings["opacity"] := Max(1, Min(10, IniRead(profileFileName, "Crosshair", "Opacity", settings["opacity"])))
        profileSettings["visible"] := IniRead(profileFileName, "Crosshair", "Visible", settings["visible"])
        profileSettings["rightClickHide"] := IniRead(profileFileName, "Crosshair", "RightClickHide", settings["rightClickHide"])
        profileSettings["rightClickMode"] := IniRead(profileFileName, "Crosshair", "RightClickMode", settings["rightClickMode"])
        profileSettings["outlineEnabled"] := IniRead(profileFileName, "Crosshair", "OutlineEnabled", settings["outlineEnabled"])
        profileSettings["outlineColor"] := IniRead(profileFileName, "Crosshair", "OutlineColor", settings["outlineColor"])
        profileSettings["outlineThickness"] := IniRead(profileFileName, "Crosshair", "OutlineThickness", settings["outlineThickness"])
        profileSettings["zoomEnabled"] := IniRead(profileFileName, "Zoom", "Enabled", settings["zoomEnabled"])
        profileSettings["zoomHotkey"] := IniRead(profileFileName, "Zoom", "Hotkey", settings["zoomHotkey"])
        profileSettings["zoomToggleMode"] := IniRead(profileFileName, "Zoom", "ToggleMode", settings["zoomToggleMode"])
        
        lines := Map()
        lines["top"] := IniRead(profileFileName, "Lines", "Top", settings["lines"]["top"])
        lines["bottom"] := IniRead(profileFileName, "Lines", "Bottom", settings["lines"]["bottom"])
        lines["left"] := IniRead(profileFileName, "Lines", "Left", settings["lines"]["left"])
        lines["right"] := IniRead(profileFileName, "Lines", "Right", settings["lines"]["right"])
        profileSettings["lines"] := lines

        settings["profiles"][profileName] := profileSettings

        profileList.Add([profileName])
        
        return true
    } catch {
        return false
    }
}

IsInArray(arr, value) {
    for item in arr {
        if (item = value) {
            return true
        }
    }
    return false
}

LoadSettings() {
    if FileExist("currentsettings.ini") {
        try {
            settings["length"] := IniRead("currentsettings.ini", "Crosshair", "Length", settings["length"])
            settings["thickness"] := IniRead("currentsettings.ini", "Crosshair", "Thickness", settings["thickness"])
            settings["gap"] := IniRead("currentsettings.ini", "Crosshair", "Gap", settings["gap"])
            settings["color"] := IniRead("currentsettings.ini", "Crosshair", "Color", settings["color"])
            settings["opacity"] := Max(1, Min(10, IniRead("currentsettings.ini", "Crosshair", "Opacity", settings["opacity"])))
            settings["visible"] := IniRead("currentsettings.ini", "Crosshair", "Visible", settings["visible"])
            settings["rightClickHide"] := IniRead("currentsettings.ini", "Crosshair", "RightClickHide", settings["rightClickHide"])
            settings["rightClickMode"] := IniRead("currentsettings.ini", "Crosshair", "RightClickMode", settings["rightClickMode"])
            settings["outlineEnabled"] := IniRead("currentsettings.ini", "Crosshair", "OutlineEnabled", settings["outlineEnabled"])
            settings["outlineColor"] := IniRead("currentsettings.ini", "Crosshair", "OutlineColor", settings["outlineColor"])
            settings["outlineThickness"] := IniRead("currentsettings.ini", "Crosshair", "OutlineThickness", settings["outlineThickness"])
            
            settings["zoomEnabled"] := IniRead("currentsettings.ini", "Zoom", "Enabled", settings["zoomEnabled"])
            settings["zoomHotkey"] := IniRead("currentsettings.ini", "Zoom", "Hotkey", settings["zoomHotkey"])
            settings["zoomToggleMode"] := IniRead("currentsettings.ini", "Zoom", "ToggleMode", settings["zoomToggleMode"])

            settings["lines"]["top"] := IniRead("currentsettings.ini", "Lines", "Top", settings["lines"]["top"])
            settings["lines"]["bottom"] := IniRead("currentsettings.ini", "Lines", "Bottom", settings["lines"]["bottom"])
            settings["lines"]["left"] := IniRead("currentsettings.ini", "Lines", "Left", settings["lines"]["left"])
            settings["lines"]["right"] := IniRead("currentsettings.ini", "Lines", "Right", settings["lines"]["right"])

            lengthUpDown.Value := settings["length"]
            thicknessUpDown.Value := settings["thickness"]
            gapUpDown.Value := settings["gap"]
            opacityUpDown.Value := settings["opacity"]
            outlineThicknessUpDown.Value := settings["outlineThickness"]
            hideBtn.Text := settings["visible"] ? "Hide Crosshair" : "Show Crosshair"
            
            zoomEnabledCB.Value := settings["zoomEnabled"] ? 1 : 0
            zoomHotkeyEdit.Value := settings["zoomHotkey"]
            zoomModeDropdown.Value := settings["zoomToggleMode"] ? 2 : 1

            colorName := GetColorNameByHex(settings["color"])
            items := ["Green", "Red", "Blue", "White", "Black", "Yellow", "Cyan", "Magenta", "Orange"]
            loop items.Length {
                if (items[A_Index] = colorName) {
                    colorDropdown.Value := A_Index
                    break
                }
            }

            outlineColorName := GetColorNameByHex(settings["outlineColor"])
            outlineItems := ["Black", "White", "Red", "Blue", "Green", "Yellow", "Cyan", "Magenta", "Orange"]
            loop outlineItems.Length {
                if (outlineItems[A_Index] = outlineColorName) {
                    outlineColorDropdown.Value := A_Index
                    break
                }
            }

            topCB.Value := settings["lines"]["top"] ? 1 : 0
            bottomCB.Value := settings["lines"]["bottom"] ? 1 : 0
            leftCB.Value := settings["lines"]["left"] ? 1 : 0
            rightCB.Value := settings["lines"]["right"] ? 1 : 0
            rightClickToggleCB.Value := settings["rightClickHide"] ? 1 : 0
            outlineEnabledCB.Value := settings["outlineEnabled"] ? 1 : 0
            rightClickModeDropdown.Value := (settings["rightClickMode"] = "hold") ? 1 : 2

            LoadProfilesFromFiles()
        }
    } else if FileExist("settings.ini") {
        try {
            settings["length"] := IniRead("settings.ini", "Crosshair", "Length", settings["length"])
            settings["thickness"] := IniRead("settings.ini", "Crosshair", "Thickness", settings["thickness"])
            settings["gap"] := IniRead("settings.ini", "Crosshair", "Gap", settings["gap"])
            settings["color"] := IniRead("settings.ini", "Crosshair", "Color", settings["color"])
            settings["opacity"] := Max(1, Min(10, IniRead("settings.ini", "Crosshair", "Opacity", settings["opacity"])))
            settings["visible"] := IniRead("settings.ini", "Crosshair", "Visible", settings["visible"])
            settings["rightClickHide"] := IniRead("settings.ini", "Crosshair", "RightClickHide", settings["rightClickHide"])
            settings["rightClickMode"] := IniRead("settings.ini", "Crosshair", "RightClickMode", settings["rightClickMode"])
            settings["outlineEnabled"] := IniRead("settings.ini", "Crosshair", "OutlineEnabled", settings["outlineEnabled"])
            settings["outlineColor"] := IniRead("settings.ini", "Crosshair", "OutlineColor", settings["outlineColor"])
            settings["outlineThickness"] := IniRead("settings.ini", "Crosshair", "OutlineThickness", settings["outlineThickness"])
            
            settings["zoomEnabled"] := IniRead("settings.ini", "Zoom", "Enabled", settings["zoomEnabled"])
            settings["zoomHotkey"] := IniRead("settings.ini", "Zoom", "Hotkey", settings["zoomHotkey"])
            settings["zoomToggleMode"] := IniRead("settings.ini", "Zoom", "ToggleMode", settings["zoomToggleMode"])

            settings["lines"]["top"] := IniRead("settings.ini", "Lines", "Top", settings["lines"]["top"])
            settings["lines"]["bottom"] := IniRead("settings.ini", "Lines", "Bottom", settings["lines"]["bottom"])
            settings["lines"]["left"] := IniRead("settings.ini", "Lines", "Left", settings["lines"]["left"])
            settings["lines"]["right"] := IniRead("settings.ini", "Lines", "Right", settings["lines"]["right"])

            lengthUpDown.Value := settings["length"]
            thicknessUpDown.Value := settings["thickness"]
            gapUpDown.Value := settings["gap"]
            opacityUpDown.Value := settings["opacity"]
            outlineThicknessUpDown.Value := settings["outlineThickness"]
            hideBtn.Text := settings["visible"] ? "Hide Crosshair" : "Show Crosshair"
            
            zoomEnabledCB.Value := settings["zoomEnabled"] ? 1 : 0
            zoomHotkeyEdit.Value := settings["zoomHotkey"]
            zoomModeDropdown.Value := settings["zoomToggleMode"] ? 2 : 1

            colorName := GetColorNameByHex(settings["color"])
            items := ["Green", "Red", "Blue", "White", "Black", "Yellow", "Cyan", "Magenta", "Orange"]
            loop items.Length {
                if (items[A_Index] = colorName) {
                    colorDropdown.Value := A_Index
                    break
                }
            }

            outlineColorName := GetColorNameByHex(settings["outlineColor"])
            outlineItems := ["Black", "White", "Red", "Blue", "Green", "Yellow", "Cyan", "Magenta", "Orange"]
            loop outlineItems.Length {
                if (outlineItems[A_Index] = outlineColorName) {
                    outlineColorDropdown.Value := A_Index
                    break
                }
            }

            topCB.Value := settings["lines"]["top"] ? 1 : 0
            bottomCB.Value := settings["lines"]["bottom"] ? 1 : 0
            leftCB.Value := settings["lines"]["left"] ? 1 : 0
            rightCB.Value := settings["lines"]["right"] ? 1 : 0
            rightClickToggleCB.Value := settings["rightClickHide"] ? 1 : 0
            outlineEnabledCB.Value := settings["outlineEnabled"] ? 1 : 0
            rightClickModeDropdown.Value := (settings["rightClickMode"] = "hold") ? 1 : 2
            
            FileMove("settings.ini", "currentsettings.ini")

            LoadProfilesFromFiles()
        }
    }
}

SaveSettings() {
    IniWrite(settings["length"], "currentsettings.ini", "Crosshair", "Length")
    IniWrite(settings["thickness"], "currentsettings.ini", "Crosshair", "Thickness")
    IniWrite(settings["gap"], "currentsettings.ini", "Crosshair", "Gap")
    IniWrite(settings["color"], "currentsettings.ini", "Crosshair", "Color")
    IniWrite(settings["opacity"], "currentsettings.ini", "Crosshair", "Opacity")
    IniWrite(settings["visible"], "currentsettings.ini", "Crosshair", "Visible")
    IniWrite(settings["rightClickHide"], "currentsettings.ini", "Crosshair", "RightClickHide")
    IniWrite(settings["rightClickMode"], "currentsettings.ini", "Crosshair", "RightClickMode")
    IniWrite(settings["outlineEnabled"], "currentsettings.ini", "Crosshair", "OutlineEnabled")
    IniWrite(settings["outlineColor"], "currentsettings.ini", "Crosshair", "OutlineColor")
    IniWrite(settings["outlineThickness"], "currentsettings.ini", "Crosshair", "OutlineThickness")
    
    IniWrite(settings["zoomEnabled"], "currentsettings.ini", "Zoom", "Enabled")
    IniWrite(settings["zoomHotkey"], "currentsettings.ini", "Zoom", "Hotkey")
    IniWrite(settings["zoomToggleMode"], "currentsettings.ini", "Zoom", "ToggleMode")

    IniWrite(settings["lines"]["top"], "currentsettings.ini", "Lines", "Top")
    IniWrite(settings["lines"]["bottom"], "currentsettings.ini", "Lines", "Bottom")
    IniWrite(settings["lines"]["left"], "currentsettings.ini", "Lines", "Left")
    IniWrite(settings["lines"]["right"], "currentsettings.ini", "Lines", "Right")

    SaveProfileList()
}

GuiClose(*) {
    SaveSettings()
    
    if (zoomActive) {
        StopZoom()
    }
    
    for part, gui in crosshair.OwnProps() {
        try gui.Destroy()
    }
    for part, gui in outline.OwnProps() {
        try gui.Destroy()
    }
    ExitApp()
}