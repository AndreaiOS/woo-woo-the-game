//
//  Singleton.m
//  Guide me Right
//
//  Created by Andrea Murru on 13/08/13.
//  Copyright (c) 2013 Andrea Murru. All rights reserved.
//


#import "singleton.h"


@implementation singleton

NSMutableArray *listaId;
NSMutableArray *listaNomi;
NSMutableArray *listaCodici;

NSString *FBAT;
NSString *setting;
NSString *scelto;

NSInteger sceltoInt;
NSInteger numero_partite;
NSInteger numero_partite_mamma;

NSInteger punteggio_massimo;
NSInteger punteggio_massimo_mamma;

NSInteger punti_totali;
NSInteger punti_totali_mamma;

NSInteger audio;
NSInteger sound;
NSInteger vibro;

NSInteger punteggio_temp;
NSInteger punteggio_temp_mamma;

NSInteger first_time;
NSInteger first_time_mamma;


bool _gameCenterEnabled;
NSString *_leaderboardIdentifier;

static singleton *sharedClass = nil;

+(NSInteger)is_first_time {
    first_time = [[NSUserDefaults standardUserDefaults] integerForKey: @"first"];

    return first_time;
}

+(void)set_first_time {
    first_time = 1;
    [[NSUserDefaults standardUserDefaults] setInteger: first_time forKey:@"first"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSInteger)is_first_time_mamma {
    first_time_mamma = [[NSUserDefaults standardUserDefaults] integerForKey: @"first_mamma"];
    
    return first_time_mamma;
}

+(void)set_first_time_mamma {
    first_time_mamma = 1;
    [[NSUserDefaults standardUserDefaults] setInteger: first_time forKey:@"first_mamma"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)setGameCenterEnabled:(BOOL)gameCenterEnabled {
    _gameCenterEnabled = gameCenterEnabled;
}

+(NSInteger)getGameCenterEnabled {
    return _gameCenterEnabled;
}

+(void)setLeaderboardIdentifier:(NSString*)leaderboardIdentifier {
    _leaderboardIdentifier = leaderboardIdentifier;
}

+(NSString*)getLeaderBoardIdentifier {
    return _leaderboardIdentifier;
}

+(void)cambia_sound:(NSInteger)acceso {
    sound = acceso;
    [[NSUserDefaults standardUserDefaults] setInteger: sound forKey:@"sound"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSInteger)is_sound {
    return sound;
}

+(void)cambia_audio:(NSInteger)acceso {
    audio = acceso;
    [[NSUserDefaults standardUserDefaults] setInteger: audio forKey:@"audio"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSInteger)is_audio {
    return audio;
}

+(void)cambia_vibro:(NSInteger)acceso {
    vibro = acceso;
    [[NSUserDefaults standardUserDefaults] setInteger: vibro forKey:@"vibro"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSInteger)is_vibro {
    return vibro;
}

+(void)set_punteggio:(NSInteger)punteggio {
    punteggio_massimo = punteggio;
    [[NSUserDefaults standardUserDefaults] setInteger: punteggio_massimo forKey:@"punteggio_massimo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSInteger)get_punteggio {
    punteggio_massimo = [[NSUserDefaults standardUserDefaults] integerForKey: @"punteggio_massimo"];
    return punteggio_massimo;
}

+(void)set_punteggio_mamma:(NSInteger)punteggio_mamma {
    punteggio_massimo_mamma = punteggio_mamma;
    [[NSUserDefaults standardUserDefaults] setInteger: punteggio_massimo_mamma forKey:@"punteggio_massimo_mamma"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSInteger)get_punteggio_mamma {
    punteggio_massimo_mamma = [[NSUserDefaults standardUserDefaults] integerForKey: @"punteggio_massimo_mamma"];
    return punteggio_massimo_mamma;
}

+(void)aggiungi_partita_giocata {
    numero_partite = [[NSUserDefaults standardUserDefaults] integerForKey: @"numero_partite"];
    if(numero_partite) {
        numero_partite = numero_partite + 1;
    } else {
        numero_partite = 1;
    }
    [[NSUserDefaults standardUserDefaults] setInteger: numero_partite forKey:@"numero_partite"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

+(NSInteger)get_partita_giocata {
    numero_partite = [[NSUserDefaults standardUserDefaults] integerForKey: @"numero_partite"];
    return numero_partite;
}

+(void)aggiungi_partita_giocata_mamma {
    numero_partite_mamma = [[NSUserDefaults standardUserDefaults] integerForKey: @"numero_partite_mamma"];
    if(numero_partite_mamma) {
        numero_partite_mamma = numero_partite_mamma + 1;
    } else {
        numero_partite_mamma = 1;
    }
    [[NSUserDefaults standardUserDefaults] setInteger: numero_partite_mamma forKey:@"numero_partite_mamma"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+(NSInteger)get_partita_giocata_mamma {
    numero_partite_mamma = [[NSUserDefaults standardUserDefaults] integerForKey: @"numero_partite_mamma"];
    return numero_partite_mamma;
}

+(void)aggiungi_punti_totali:(NSInteger)punteggio {
    punti_totali = [[NSUserDefaults standardUserDefaults] integerForKey: @"punti_totali"];
    if(punti_totali)
        punti_totali = punti_totali + punteggio;
    else
        punti_totali = punteggio;
    [[NSUserDefaults standardUserDefaults] setInteger: punti_totali forKey:@"punti_totali"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSInteger)get_punti_totali {
    punti_totali = [[NSUserDefaults standardUserDefaults] integerForKey: @"punti_totali"];
    return punti_totali;
}

+(void)cancella_punteggi{
    punti_totali = 0;
    numero_partite = 0;
    punteggio_massimo = 0;
    [[NSUserDefaults standardUserDefaults] setInteger: 0 forKey:@"punti_totali"];
    [[NSUserDefaults standardUserDefaults] setInteger: 0 forKey:@"numero_partite"];
    [[NSUserDefaults standardUserDefaults] setInteger: 0 forKey:@"punteggio_massimo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)aggiungi_punti_totali_mamma:(NSInteger)punteggio_mamma {
    punti_totali_mamma = [[NSUserDefaults standardUserDefaults] integerForKey: @"punti_totali_mamma"];
    if(punti_totali_mamma)
        punti_totali_mamma = punti_totali_mamma + punteggio_mamma;
    else
        punti_totali_mamma = punteggio_mamma;
    [[NSUserDefaults standardUserDefaults] setInteger: punti_totali_mamma forKey:@"punti_totali_mamma"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSInteger)get_punti_totali_mamma {
    punti_totali_mamma = [[NSUserDefaults standardUserDefaults] integerForKey: @"punti_totali_mamma"];
    return punti_totali_mamma;
}

+(void)cancella_punteggi_mamma{
    punti_totali_mamma = 0;
    numero_partite_mamma = 0;
    punteggio_massimo_mamma = 0;
    [[NSUserDefaults standardUserDefaults] setInteger: 0 forKey:@"punti_totali_mamma"];
    [[NSUserDefaults standardUserDefaults] setInteger: 0 forKey:@"numero_partite_mamma"];
    [[NSUserDefaults standardUserDefaults] setInteger: 0 forKey:@"punteggio_massimo_mamma"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


// Con questo metodo imposto il valore dell'array condiviso
+ (void)impostaArrayId:(NSMutableArray *)valore{
	listaId = valore;
}

// Con questo metodo, prelevo il valore dell'array condiviso da qualsiasi classe
+ (NSMutableArray *)ritornaArrayId{
	return listaId;
}

// Con questo metodo imposto il valore dell'array condiviso
+ (void)impostaArrayNomi:(NSMutableArray *)valore{
	listaNomi = valore;
}

// Con questo metodo, prelevo il valore dell'array condiviso da qualsiasi classe
+ (NSMutableArray *)ritornaArrayNomi{
	return listaNomi;
}

// Con questo metodo imposto il valore dell'array condiviso
+ (void)impostaArrayCodici:(NSMutableArray *)valore{
	listaCodici = valore;
}

// Con questo metodo, prelevo il valore dell'array condiviso da qualsiasi classe
+ (NSMutableArray *)ritornaArrayCodici{
	return listaCodici;
}

+ (void)impostaScelto:(NSString *)valore{
	scelto = valore;
}


+ (NSString *)ritornaScelto{
	return scelto;
}

+ (void)impostaSetting:(NSString *)valore{
	setting = valore;
}


+ (NSString *)ritornaSetting{
	return setting;
}

+ (void)impostaSceltoInt:(NSInteger)valore{
    sceltoInt = valore;
}


+ (NSInteger)ritornaSceltoInt{
	return sceltoInt;
}

+ (void)impostaFBAT:(NSString *)valore{
	FBAT = valore;
}

+ (NSString *)ritornaFBAT{
	return FBAT;
}



+ (singleton *)sharedManager
{
    @synchronized(self) {
        if (sharedClass == nil) {
            //[[self alloc] init]; // assignment not done here
        }
    }
    return sharedClass;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedClass == nil) {
            sharedClass = [super allocWithZone:zone];
            return sharedClass;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

+(void)set_punteggio_temp:(NSInteger)punteggio {
    punteggio_temp = punteggio;
}

+(NSInteger)get_punteggio_temp {
    return punteggio_temp;
}

+(void)set_punteggio_temp_mamma:(NSInteger)punteggio_mamma {
    punteggio_temp_mamma = punteggio_mamma;
}

+(NSInteger)get_punteggio_temp_mamma {
    return punteggio_temp_mamma;
}

@end
