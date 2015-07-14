#import "LocalizedCurrentLocation.h"

@implementation LocalizedCurrentLocation

+ (NSString *)currentLocationStringForCurrentLanguage {

    NSDictionary *localizedStringDictionary = @{@"nl": @"Huidige locatie",
                                               @"en": @"Current Location",
                                               @"fr": @"Lieu actuel",
                                               @"de": @"Aktueller Ort",
                                               @"it": @"Posizione attuale",
                                               @"ja": @"現在地",
                                               @"es": @"Ubicación actual",
                                               @"ar": @"الموقع الحالي",
                                               @"ca": @"Ubicació actual",
                                               @"cs": @"Současná poloha",
                                               @"da": @"Aktuel lokalitet",
                                               @"el": @"Τρέχουσα τοποθεσία",
                                               @"en-GB": @"Current Location",
                                               @"fi": @"Nykyinen sijainti",
                                               @"he": @"מיקום נוכחי",
                                               @"hr": @"Trenutna lokacija",
                                               @"hu": @"Jelenlegi helyszín",
                                               @"id": @"Lokasi Sekarang",
                                               @"ko": @"현재 위치",
                                               @"ms": @"Lokasi Semasa",
                                               @"no": @"Nåværende plassering",
                                               @"pl": @"Bieżące położenie",
                                               @"pt": @"Localização Atual",
                                               @"pt-PT": @"Localização actual",
                                               @"ro": @"Loc actual",
                                               @"ru": @"Текущее размещение",
                                               @"sk": @"Aktuálna poloha",
                                               @"sv": @"Nuvarande plats",
                                               @"th": @"ที่ตั้งปัจจุบัน",
                                               @"tr": @"Şu Anki Yer",
                                               @"uk": @"Поточне місце",
                                               @"vi": @"Vị trí Hiện tại",
                                               @"zh-CN": @"当前位置",
                                               @"zh-TW": @"目前位置"};
    
    NSString *localizedString;
    NSString *currentLanguageCode = [[NSLocale currentLocale] objectForKey: NSLocaleLanguageCode];
    
    if ([localizedStringDictionary valueForKey:currentLanguageCode]) {
        localizedString = [NSString stringWithString:[localizedStringDictionary valueForKey:currentLanguageCode]];
    } else {
        localizedString = [NSString stringWithString:[localizedStringDictionary valueForKey:@"en"]];
    }
    
    return localizedString;
}

@end
