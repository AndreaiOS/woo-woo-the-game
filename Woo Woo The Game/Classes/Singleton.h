//
//  Singleton.h
//  Guide me Right
//
//  Created by Andrea Murru on 13/08/13.
//  Copyright (c) 2013 Andrea Murru. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface singleton : NSObject {
    
}

+(NSInteger)is_first_time;
+(void)set_first_time;
+(NSInteger)is_first_time_mamma;
+(void)set_first_time_mamma;


+ (void)impostaArrayId:(NSMutableArray *)valore;
+ (NSMutableArray *)ritornaArrayId;

+ (void)impostaArrayNomi:(NSMutableArray *)valore;
+ (NSMutableArray *)ritornaArrayNomi;

+ (void)impostaArrayCodici:(NSMutableArray *)valore;
+ (NSMutableArray *)ritornaArrayCodici;

+ (void)impostaScelto:(NSString *)valore;
+ (NSString *)ritornaScelto;

+ (void)impostaSetting:(NSString *)valore;
+ (NSString *)ritornaSetting;

+ (void)impostaSceltoInt:(NSInteger)valore;
+ (NSInteger)ritornaSceltoInt;

+ (void)impostaFBAT:(NSString *)valore;
+ (NSString *)ritornaFBAT;

+(void)set_punteggio:(NSInteger)punteggio;
+(void)aggiungi_partita_giocata;
+(NSInteger)get_punteggio;
+(NSInteger)get_partita_giocata;
+(void)set_punteggio_mamma:(NSInteger)punteggio_mamma;
+(void)aggiungi_partita_giocata_mamma;
+(NSInteger)get_punteggio_mamma;
+(NSInteger)get_partita_giocata_mamma;

+(void)aggiungi_punti_totali:(NSInteger)punteggio;
+(NSInteger)get_punti_totali;
+(void)aggiungi_punti_totali_mamma:(NSInteger)punteggio_mamma;
+(NSInteger)get_punti_totali_mamma;


+(void)cancella_punteggi;
+(void)cancella_punteggi_mamma;

+(void)cambia_sound:(NSInteger)acceso ;

+(NSInteger)is_sound;

+(void)cambia_audio:(NSInteger)acceso ;
+(NSInteger)is_audio ;
+(void)cambia_vibro:(NSInteger)acceso;
+(NSInteger)is_vibro;

+(void)set_punteggio_temp:(NSInteger)punteggio;
+(NSInteger)get_punteggio_temp;
+(void)set_punteggio_temp_mamma:(NSInteger)punteggio_mamma;
+(NSInteger)get_punteggio_temp_mamma;


+(void)setGameCenterEnabled:(BOOL)gameCenterEnabled;

+(NSInteger)getGameCenterEnabled;

+(void)setLeaderboardIdentifier:(NSString*)leaderboardIdentifier;

+(NSString*)getLeaderBoardIdentifier;

@end

