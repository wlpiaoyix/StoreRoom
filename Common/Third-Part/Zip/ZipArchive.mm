//
//  ZipArchive.mm
//  
//
//  Created by aish on 08-9-11.
//  acsolu@gmail.com
//  Copyright 2008  Inc. All rights reserved.
//

#import "ZipArchive.h"
#import "zlib.h"
#import "zconf.h"
#import "ConfigManage.h"
#import "JSON.h"

@interface ZipArchive (Private){

}
@end



@implementation ZipArchive

-(id) init
{
	if( self=[super init] )
	{
        _synarraypath = [NSObject new];
		_zipFile = NULL ;
	}
	return self;
}

-(void) dealloc
{
	[self closeZipFile];
    [self closeUnzipFile];
}

-(BOOL) createZipFile:(NSString*) zipFile append:(int) append
{
	_zipFile = zipOpen( (const char*)[zipFile UTF8String], append );
	if( !_zipFile ) 
		return NO;
    _zipPath = zipFile;
	return YES;
}

-(BOOL) createZipFile:(NSString*) zipFile password:(NSString*) password append:(int) append
{
	_password = password;
	return [self createZipFile:zipFile append:append];
}

-(BOOL) addFileToZip:(NSData*) data newname:(NSString*) newname;
{
	if( !_zipFile )
		return NO;
//	tm_zip filetime;
	time_t current;
	time( &current );
	
	zip_fileinfo zipInfo = {0};
//	zipInfo.dosDate = (unsigned long) current;
	
	int ret ;
	if( [_password length] == 0 )
	{
		ret = zipOpenNewFileInZip( _zipFile,
								  (const char*) [newname UTF8String],
								  &zipInfo,
								  NULL,0,
								  NULL,0,
								  NULL,//comment
								  Z_DEFLATED,
								  Z_DEFAULT_COMPRESSION );
	}
	else
	{
		uLong crcValue = crc32( 0L,NULL, 0L );
		crcValue = crc32( crcValue, (const Bytef*)[data bytes], (uInt)[data length] );
		ret = zipOpenNewFileInZip3( _zipFile,
								  (const char*) [newname UTF8String],
								  &zipInfo,
								  NULL,0,
								  NULL,0,
								  NULL,//comment
								  Z_DEFLATED,
								  Z_DEFAULT_COMPRESSION,
								  0,
								  15,
								  8,
								  Z_DEFAULT_STRATEGY,
								  [_password cStringUsingEncoding:NSASCIIStringEncoding],
								  crcValue );
	}
	if( ret!=Z_OK )
	{
		return NO;
	}
	if( data==nil )
	{
        return NO;
	}
	unsigned int dataLen = (unsigned int)[data length];
	ret = zipWriteInFileInZip( _zipFile, (const void*)[data bytes], dataLen);
	if( ret!=Z_OK )
	{
		return NO;
	}
	ret = zipCloseFileInZip( _zipFile );
	if( ret!=Z_OK )
		return NO;
    NSError *error = nil;
    NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@",_zipPath,newname] error:&error];
    if( fileDictionary )
    {
        NSDate* fileDate = (NSDate*)[fileDictionary objectForKey:NSFileModificationDate];
        if( fileDate )
        {
            // some application does use dosDate, but tmz_date instead
            //	zipInfo.dosDate = [fileDate timeIntervalSinceDate:[self Date1980] ];
            NSCalendar* currCalendar = [NSCalendar currentCalendar];
            uint flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit |
            NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ;
            NSDateComponents* dc = [currCalendar components:flags fromDate:fileDate];
            zipInfo.tmz_date.tm_sec = (uInt)[dc second];
            zipInfo.tmz_date.tm_min = (uInt)[dc minute];
            zipInfo.tmz_date.tm_hour = (uInt)[dc hour];
            zipInfo.tmz_date.tm_mday = (uInt)[dc day];
            zipInfo.tmz_date.tm_mon = (uInt)[dc month] - 1;
            zipInfo.tmz_date.tm_year = (uInt)[dc year];
            
        }
    }
	return YES;
}

-(BOOL) closeZipFile
{
	_password = nil;
	if( _zipFile==NULL )
		return NO;
	BOOL ret =  zipClose( _zipFile,NULL )==Z_OK?YES:NO;
	_zipFile = NULL;
	return ret;
}

-(BOOL) openUnzipFile:(NSString*) zipFile
{
	_unzFile = unzOpen( (const char*)[zipFile UTF8String] );
	if( _unzFile )
	{
		unz_global_info  globalInfo = {0};
		if( unzGetGlobalInfo(_unzFile, &globalInfo )==UNZ_OK )
		{
			NSLog(@"%lu entries in the zip file",globalInfo.number_entry);
            _zipPath = zipFile;
		}
	}
	return _unzFile!=NULL;
}
-(BOOL) openUnzipFile:(NSString*) zipFile password:(NSString*) password
{
	_password = password;
	return [self openUnzipFile:zipFile];
}
-(BOOL) unzipFileTo:(NSString*) path overWrite:(BOOL) overwrite
{
	BOOL success = YES;
	int ret = unzGoToFirstFile( _unzFile );
	unsigned char	buffer[4096] = {0};
	NSFileManager* fman = [NSFileManager defaultManager];
	if( ret!=UNZ_OK )
	{
		[self outputErrorMessage:@"Failed"];
	}
	
	do{
		if( [_password length]==0 )
			ret = unzOpenCurrentFile( _unzFile );
		else
			ret = unzOpenCurrentFilePassword( _unzFile, [_password cStringUsingEncoding:NSASCIIStringEncoding] );
		if( ret!=UNZ_OK )
		{
			[self outputErrorMessage:@"Error occurs"];
			success = NO;
			break;
		}
		// reading data and write to file
		int read ;
		unz_file_info	fileInfo ={0};
		ret = unzGetCurrentFileInfo(_unzFile, &fileInfo, NULL, 0, NULL, 0, NULL, 0);
		if( ret!=UNZ_OK )
		{
			[self outputErrorMessage:@"Error occurs while getting file info"];
			success = NO;
			unzCloseCurrentFile( _unzFile );
			break;
		}
		char* filename = (char*) malloc( fileInfo.size_filename +1 );
		unzGetCurrentFileInfo(_unzFile, &fileInfo, filename, fileInfo.size_filename + 1, NULL, 0, NULL, 0);
		filename[fileInfo.size_filename] = '\0';

		// check if it contains directory
		NSString * strPath = [NSString  stringWithCString:filename encoding:NSUTF8StringEncoding];
         strPath = [strPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		BOOL isDirectory = NO;
		if( filename[fileInfo.size_filename-1]=='/' || filename[fileInfo.size_filename-1]=='\\')
			isDirectory = YES;
		free( filename );
		if( [strPath rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/\\"]].location!=NSNotFound )
		{// contains a path
			strPath = [strPath stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
		}
		NSString* fullPath = [path stringByAppendingPathComponent:strPath];
		if( isDirectory )
			[fman createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
		else
			[fman createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
		if( [fman fileExistsAtPath:fullPath] && !isDirectory && !overwrite )
		{
			if( ![self OverWrite:fullPath] )
			{
				unzCloseCurrentFile( _unzFile );
				ret = unzGoToNextFile( _unzFile );
				continue;
			}
		}
        
		FILE* fp = fopen( (const char*)[fullPath UTF8String], "wb");
		while( fp )
		{
			read=unzReadCurrentFile(_unzFile, buffer, 4096);
			if( read > 0 )
            {
                if(callbackhub){
                    callbackhub(read,buffer);
                }else if (_delegate&&[_delegate respondsToSelector:@selector(handelUnzipingBuffer:)]) {
                    [_delegate handelUnzipingBuffer:buffer];
                }
				fwrite(buffer, read, 1, fp );
			}
			else if( read<0 )
			{
				[self outputErrorMessage:@"Failed to reading zip file"];
				break;
			}
			else
				break;				
		}
		if( fp )
		{
			fclose( fp );
			// set the orignal datetime property
			NSDate* orgDate = nil;
			
			//{{ thanks to brad.eaton for the solution
			NSDateComponents *dc = [[NSDateComponents alloc] init];
			
			dc.second = fileInfo.tmu_date.tm_sec;
			dc.minute = fileInfo.tmu_date.tm_min;
			dc.hour = fileInfo.tmu_date.tm_hour;
			dc.day = fileInfo.tmu_date.tm_mday;
			dc.month = fileInfo.tmu_date.tm_mon+1;
			dc.year = fileInfo.tmu_date.tm_year;
			
			NSCalendar *gregorian = [[NSCalendar alloc] 
									 initWithCalendarIdentifier:NSGregorianCalendar];
			
			orgDate = [gregorian dateFromComponents:dc] ;
			//}}
			
			
			NSDictionary* attr = [NSDictionary dictionaryWithObject:orgDate forKey:NSFileModificationDate]; //[[NSFileManager defaultManager] fileAttributesAtPath:fullPath traverseLink:YES];
			if( attr )
			{
				//		[attr  setValue:orgDate forKey:NSFileCreationDate];
				if( ![[NSFileManager defaultManager] setAttributes:attr ofItemAtPath:fullPath error:nil] )
				{
					// cann't set attributes 
					NSLog(@"Failed to set attributes");
				}
				
			}
		
			
			
		}
		unzCloseCurrentFile( _unzFile );
		ret = unzGoToNextFile( _unzFile );
	}while( ret==UNZ_OK && UNZ_OK!=UNZ_END_OF_LIST_OF_FILE );
	return success;
}
//-(BOOL) moveVernier
-(NSData*) getUnzipFile:(NSString*) filePath{
    int index = 0;
    NSArray *allzipPaths = [self getAllUnzipPath];
    for (NSString *path in allzipPaths) {
        if ([filePath isEqualToString:path]) {
            break;
        }
        index++;
    }
    NSMutableData *dataResult = [NSMutableData new];
    [self ergodicPath:^int(int index) {
        [self unZipFile:^int(NSString *strPath, BOOL isDirectory) {
            int read;
            unsigned char	buffer[4096] = {0};
            NSFileManager* fman = [NSFileManager defaultManager];
            NSString* fullPath = [_zipPath stringByAppendingPathComponent:strPath];
           
            if( isDirectory )
                [fman createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
            else
                [fman createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
            if( [fman fileExistsAtPath:fullPath] && !isDirectory && /* DISABLES CODE */ (!YES)){
                if( ![self OverWrite:fullPath] ) {
                    unzCloseCurrentFile( _unzFile );
                    return -1;
                }
            }
           
           if ([strPath isEqualToString:filePath]) {
               read = 0;
               while(read!=-1)
               {
                   read=unzReadCurrentFile(_unzFile, buffer, 4096);
                   if( read > 0 )
                   {
                       if (_delegate&&[_delegate respondsToSelector:@selector(handelUnzipingBuffer:)]) {
                           [_delegate handelUnzipingBuffer:buffer];
                       }
                       [dataResult appendBytes:buffer length:read];
                   }
                   else if( read<0 )
                   {
                       [self outputErrorMessage:@"Failed to reading zip file"];
                       break;
                   }
                   else
                       break;
               }
           }
            return -1;
        }];
        return -1;
    } index:index];
br:dataResult = dataResult;
    return dataResult;
}

-(BOOL) closeUnzipFile
{
	_password = nil;
    
    if( _unzFile ){
        BOOL ret = unzClose( _unzFile )==UNZ_OK;
        _unzFile = NULL;
        return ret;
    }
	return YES;
}

-(NSArray*) getAllUnzipPath{
    @synchronized(_synarraypath){
        if (_arrayPath&&[_arrayPath count]) {
            return _arrayPath;
        }
        NSString *key = [NSString stringWithFormat:@"zipmenucache%@",[_zipPath componentsSeparatedByString:@"/"].lastObject];
        
        
        NSArray *cachedata = (NSArray*)[[ConfigManage getConfigValue:key] JSONValue];
        
        if ([cachedata count]>1000) {
            _arrayPath = [NSArray arrayWithArray:cachedata];
            return _arrayPath;
        }
        NSMutableArray *temp = [NSMutableArray new];
        [self ergodicPath:^int(int index) {
            return [self unZipFile:^int(NSString *strpath, BOOL isDirectory) {
                [temp addObject:[NSString stringWithFormat:@"%@",strpath]];
                return 0;
            }];
        } index:-1];
        _arrayPath = [NSArray arrayWithArray:temp];
        [ConfigManage setConfigValue:[_arrayPath JSONRepresentation] Key:key];
        
    }
    return _arrayPath;
}
-(void) removeCaches{
    @synchronized(_synarraypath){
        _arrayPath = nil;
        NSString *key = [NSString stringWithFormat:@"zipmenucache%@",[_zipPath componentsSeparatedByString:@"/"].lastObject];
        [ConfigManage removeConfigValue:key];
    }
}

-(int) unZipFile:(CallBackHandelUnziping) callback{
    BOOL success;
    int ret;
    if([_password length]==0)
        ret = unzOpenCurrentFile(_unzFile );
    else
        ret = unzOpenCurrentFilePassword( _unzFile, [_password cStringUsingEncoding:NSASCIIStringEncoding] );
    if( ret!=UNZ_OK )
    {
        [self outputErrorMessage:@"Error occurs"];
        success = NO;
        return -1;
    }
    unz_file_info	fileInfo ={0};
    ret = unzGetCurrentFileInfo(_unzFile, &fileInfo, NULL, 0, NULL, 0, NULL, 0);
    if( ret!=UNZ_OK )
    {
        [self outputErrorMessage:@"Error occurs while getting file info"];
        success = NO;
        unzCloseCurrentFile( _unzFile );
        return -1;
    }
    char* filename = (char*) malloc( fileInfo.size_filename +1 );
    unzGetCurrentFileInfo(_unzFile, &fileInfo, filename, fileInfo.size_filename + 1, NULL, 0, NULL, 0);
    filename[fileInfo.size_filename] = '\0';
    
    // check if it contains directory
    NSString * strPath = [NSString  stringWithCString:filename encoding:NSUTF8StringEncoding];
    //  strPath = [strPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    BOOL isDirectory = NO;
    if( filename[fileInfo.size_filename-1]=='/' || filename[fileInfo.size_filename-1]=='\\')
        isDirectory = YES;
    free( filename );
    @try {
        if( [strPath rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/\\"]].location!=NSNotFound )
        {// contains a path
            strPath = [strPath stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
        }
        if (callback) {
            return callback(strPath,isDirectory);
        }
        return 0;
    }
    @finally {
        unzCloseCurrentFile( _unzFile );
    }
}
-(void) ergodicPath:(CallBackCircelErgodicPath) callBack index:(const long) index{
    int currentIndex = 0;
    if (callBack) {
        if (index>0) {
            unzGoToTargetFile(_unzFile, index);
            callBack(currentIndex);
        }else{
            int ret = unzGoToFirstFile( _unzFile );
            if( ret!=UNZ_OK )
            {
                [self outputErrorMessage:@"Failed"];
            }
            do{
                switch (callBack(currentIndex)) {
                    case -1:
                    {
                        goto br;
                    }
                        break;
                    default:
                        break;
                }
                ret = unzGoToNextFile(_unzFile);
                currentIndex++;
            }while( ret==UNZ_OK && UNZ_OK!=UNZ_END_OF_LIST_OF_FILE );
        br:currentIndex = currentIndex;
        }
    }
}

-(void) setCallBackCircelHandelUnzipingBuffer:(CallBackCircelHandelUnzipingBuffer) callback{
    callbackhub = callback;
}



#pragma mark wrapper for delegate
-(void) outputErrorMessage:(NSString*) msg
{
	if( _delegate && [_delegate respondsToSelector:@selector(ErrorMessage:)] )
		[_delegate ErrorMessage:msg];
}

-(BOOL) OverWrite:(NSString*) file
{
	if( _delegate && [_delegate respondsToSelector:@selector(OverWriteOperation:)] )
		return [_delegate OverWriteOperation:file];
	return YES;
}

#pragma mark get NSDate object for 1980-01-01
-(NSDate*) date1980
{
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setDay:1];
	[comps setMonth:1];
	[comps setYear:1980];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	NSDate *date = [gregorian dateFromComponents:comps];
	
	return date;
}


@end


