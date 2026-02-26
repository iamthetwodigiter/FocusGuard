class SystemWhitelist {
  static const Set<String> packageNames = {
    // Core Android System
    "com.android.systemui",
    "com.android.settings",
    "com.android.launcher",
    "com.android.launcher3",
    "com.android.phone",
    "com.android.dialer",
    "com.android.contacts",
    "com.android.mtp",
    "com.android.providers",
    "com.android.emergency",
    "com.android.vending", // Play Store
    "android",

    // Google System Apps
    "com.google.android.apps.nexuslauncher",
    "com.google.android.dialer",
    "com.google.android.contacts",
    "com.google.android.gsf",
    "com.google.android.gms",
    "com.google.android.setupwizard",

    // Samsung
    "com.samsung.android.oneui.home", // OneUI Launcher
    "com.samsung.android.app.launcher",
    "com.sec.android.app.launcher",
    "com.samsung.android.dialer",
    "com.android.incallui",
    "com.samsung.android.incall",
    "com.samsung.android.messaging",
    "com.samsung.android.contacts",
    "com.samsung.android.app.contacts",
    "com.samsung.android.bixby",
    "com.samsung.android.setting",
    "com.samsung.android.emergencymode",

    // Xiaomi / MIUI
    "com.miui.home", // MIUI Launcher
    "com.mi.android.globallauncher",
    "com.android.thememanager",
    "com.miui.securitycenter",
    "com.xiaomi.micloud",
    "com.xiaomi.finddevice",
    "com.miui.systemAdSolution",
    "com.android.mms", // Messages
    "com.miui.powerkeeper",
    "com.miui.securityadd",

    // Huawei / EMUI
    "com.huawei.android.launcher",
    "com.huawei.systemmanager",
    "com.huawei.android.thememanager",
    "com.huawei.phoneservice",
    "com.huawei.android.hsf",
    "com.huawei.hwid",
    "com.huawei.himovie",

    // OnePlus / OxygenOS
    "net.oneplus.launcher",
    "net.oneplus.odm",
    "com.oneplus.security",
    "com.oneplus.account",
    "com.oneplus.backuprestore",

    // Oppo / ColorOS
    "com.oppo.launcher",
    "com.coloros.safecenter",
    "com.coloros.gamespace",
    "com.oppo.contacts",

    // Vivo / FuntouchOS
    "com.vivo.launcher",
    "com.iqoo.secure",
    "com.bbk.launcher2",
    "com.vivo.safecenter",

    // Realme
    "com.realme.launcher",
    "com.coloros.phonenoareainquire",

    // Motorola
    "com.motorola.launcher3",
    "com.motorola.setupwizard",

    // Nokia
    "com.evenwell.nps",
    "com.hmdglobal.app.activation",

    // Sony
    "com.sonymobile.home",
    "com.sonymobile.xperialounge",

    // LG
    "com.lge.launcher2",
    "com.lge.launcher3",
    "com.lge.smartworld",

    // Essential System Services
    "com.android.nfc",
    "com.android.bluetoot",
    "com.android.server.telecom",
    "com.qualcomm.qti", // Qualcomm services
    "com.mediatek", // MediaTek services

    // Critical Google Apps
    "com.google.android.apps.maps",
    "com.google.android.calendar",
    "com.google.android.apps.docs",
    "com.google.android.gm", // Gmail
    "com.google.android.apps.messaging",
  };
}
