/*
 *  YTAuth.c
 *  certtest
 *
 *  Created by Anton Maryanov on 9/13/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#import "YTAuth.h"
@implementation YTAuth

+ (NSData*) signTheData:(NSData*) data
{
	NSData* sig;
	unsigned char *sigret;
	unsigned int siglen;
	EVP_PKEY *pkey;
	OpenSSL_add_all_ciphers();
	OpenSSL_add_all_digests();
	OpenSSL_add_all_algorithms();
	
	BIO *inn;
	//inn = BIO_new_file([[[NSBundle mainBundle] pathForResource:@"device_private_key.pem" ofType:nil] UTF8String], "r");
	inn = BIO_new(BIO_s_mem());
	NSData *file = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"my_key.pem" ofType:nil]];
	NSRange range;
	range.location = [file length] - 1;
	range.length = 1;
	unsigned char buf[1];
	[file getBytes:buf range:range];
	if(buf[0] == '\n')
		BIO_write(inn, [file bytes], [file length] - 1);
	else
		BIO_write(inn, [file bytes], [file length]);
	
    BIO_flush(inn);
	
	pkey = PEM_read_bio_PrivateKey(inn, NULL,NULL, NULL);
	BIO_free(inn);
	
	siglen = EVP_PKEY_size(pkey);
	sigret = (unsigned char*)malloc(siglen);
	EVP_MD_CTX md_ctx;
	EVP_SignInit(&md_ctx, EVP_get_digestbyname("SHA1"));
	EVP_SignUpdate(&md_ctx, [data bytes], [data length]);
	EVP_SignFinal (&md_ctx, sigret, &siglen, pkey);
	EVP_PKEY_free(pkey);
	sig = [NSData dataWithBytes:sigret length:siglen];
	free(sigret);
	return sig;
}

+ (NSString*) getToken
{
	NSString *res = @"";
	NSData* r1;
	NSData* hr1;
	NSData *r2;
	NSData *hmackr2;
	NSString *req;
	NSData * requestData;
	NSData *responseData;
	NSError * err;
	NSMutableURLRequest *urlRequest;
	NSURLResponse * resp;
	NSString *responseStr;
	NSArray *responseArr;
	NSArray *authArr;
	NSString *resStr;
	resp = [NSURLResponse alloc];
	err = [NSError alloc];
	NSData* cert = [@"LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURQekNDQXFpZ0F3SUJBZ0lLQTRCUllCOVBRUms3NlRBTkJna3Foa2lHOXcwQkFRc0ZBREJhTVFzd0NRWUQKVlFRR0V3SlZVekVUTUJFR0ExVUVDaE1LUVhCd2JHVWdTVzVqTGpFVk1CTUdBMVVFQ3hNTVFYQndiR1VnYVZCbwpiMjVsTVI4d0hRWURWUVFERXhaQmNIQnNaU0JwVUdodmJtVWdSR1YyYVdObElFTkJNQjRYRFRBM01EY3dOekl6Ck1EZ3dNMW9YRFRFd01EY3dOekl6TURnd00xb3dnWWN4TVRBdkJnTlZCQU1US0RNNE5URmhOamRqT0dFM01ETTMKTnpjek9HWXhOVEJsTTJGaFlUWTJOV1U1TkRFNU5tUXpOekV4Q3pBSkJnTlZCQVlUQWxWVE1Rc3dDUVlEVlFRSQpFd0pEUVRFU01CQUdBMVVFQnhNSlEzVndaWEowYVc1dk1STXdFUVlEVlFRS0V3cEJjSEJzWlNCSmJtTXVNUTh3CkRRWURWUVFMRXdacFVHaHZibVV3Z1o4d0RRWUpLb1pJaHZjTkFRRUJCUUFEZ1kwQU1JR0pBb0dCQU9XTEIxejYKMEI0M0l3SVRudFFNS0JacW51YmkxSjR4cnJOSmtvWC9GUmtjS1NoemQwZnBTRXplNi9ZcTE2ZDVjaTg1dUt0agpUSnRHRFpjcTltaFltTWc2anZUelB4b3g1Z09ib0h1NGFVeGNlZ2NHUDhtRFpUcjdPM21rZU1rV0RRVkd2Z3NLCkwwdWE0WGJZVXdiYnB6aFJTN041aWZERXJSWUt3UlljWXovVkFnTUJBQUdqZ2Qwd2dkb3dnWUlHQTFVZEl3UjcKTUhtQUZMTCtJU05FaHBWcWVkV0JKbzV6RU5pblRJNTBvVjZrWERCYU1Rc3dDUVlEVlFRR0V3SlZVekVUTUJFRwpBMVVFQ2hNS1FYQndiR1VnU1c1akxqRVZNQk1HQTFVRUN4TU1RWEJ3YkdVZ2FWQm9iMjVsTVI4d0hRWURWUVFECkV4WkJjSEJzWlNCcFVHaHZibVVnUkdWMmFXTmxJRU5CZ2dFQk1CMEdBMVVkRGdRV0JCVHBsVTJrZE5zeFpFbmEKTXFUSnVaVWdaQzM1WHpBTUJnTlZIUk1CQWY4RUFqQUFNQTRHQTFVZER3RUIvd1FFQXdJRm9EQVdCZ05WSFNVQgpBZjhFRERBS0JnZ3JCZ0VGQlFjREFUQU5CZ2txaGtpRzl3MEJBUXNGQUFPQmdRQ3FjbVNyTnFnWldGdkZJYzluCkNwMktacUVRK0ozdTNLS2h4ZUwzR05KZ2twS3JQa3R3RC8rRGhIMlFDRUNtRUNMNTI0MHVLWGkvTzFlZjZZMkIKWjM4SVFuOHVoci9oYkRXUWFpV1o2OFhQWUEvTzRFZ3lKMHp6cmlzMks3UzBPSG9vTm1uZVowcEVMMElib2ZaOApKRjhHbjRaK0I2dHR6MEtQSDdJWTJ3LzRYZz09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K" decodeBase64WithNewlines:NO];
	r1 = [NSData randomData:20];
	hr1 = [r1 SHA];
	req = [NSString stringWithFormat:@"hr1=%s", [[hr1 webSafeBase64Encode] UTF8String]];
	requestData = [req dataUsingEncoding: NSUTF8StringEncoding allowLossyConversion:YES];
	
    NSURL *applelogin1 = [NSURL URLWithString:@"http://www.google.com/youtube/accounts/applelogin1"];
	urlRequest = [NSMutableURLRequest  requestWithURL:applelogin1];
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest setHTTPBody:requestData];
	responseData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&resp error:&err];
	responseStr = [[NSString alloc] initWithBytes:[responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding];
	responseArr = [responseStr componentsSeparatedByString:@"\n"];
	NSString *r2str = [responseArr objectAtIndex:0];
	NSArray *r2Arr = [r2str componentsSeparatedByString:@"="];
	NSString *r2ResStr = [r2Arr objectAtIndex:1];
	r2 = [r2ResStr webSafeBase64Decode];
	NSString *hmackr2Str = [responseArr objectAtIndex:1];
	NSArray *hmackr2Arr = [hmackr2Str componentsSeparatedByString:@"="];
	NSString *hmackr2ResStr = [hmackr2Arr objectAtIndex:1];
	hmackr2 = [hmackr2ResStr webSafeBase64Decode];
	
	NSMutableData *signData;
	signData = [NSMutableData dataWithData:r2];
	[signData appendData:r1];
	NSData* sig = [YTAuth signTheData:signData];
	
	req = [NSString stringWithFormat:@"r1=%s&r2=%s&cert=%s&sig=%s&hr1=%s&hmackr2=%s",
	[[r1 webSafeBase64Encode] UTF8String], [[r2 webSafeBase64Encode] UTF8String],
	[[cert webSafeBase64Encode] UTF8String], [[sig webSafeBase64Encode] UTF8String],
	[[hr1 webSafeBase64Encode] UTF8String], [[hmackr2 webSafeBase64Encode] UTF8String]];
	requestData = [req dataUsingEncoding: NSUTF8StringEncoding];
    NSURL *applelogin2 = [NSURL URLWithString:@"http://www.google.com/youtube/accounts/applelogin2"];
	urlRequest = [NSMutableURLRequest  requestWithURL:applelogin2];
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest setHTTPBody:requestData];
	responseData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&resp error:&err];
	responseStr = [[NSString alloc] initWithBytes:[responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding];
	responseArr = [responseStr componentsSeparatedByString:@"\n"];
	resStr = [responseArr objectAtIndex:0];
	authArr = [resStr componentsSeparatedByString:@"="];
	res = [authArr objectAtIndex:1];
	//[res retain];
	return res;
}
@end
