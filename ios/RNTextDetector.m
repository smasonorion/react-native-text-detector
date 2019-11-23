
#import "RNTextDetector.h"

#import <React/RCTBridge.h>

#import <CoreML/CoreML.h>
#import <Vision/Vision.h>
#import <TesseractOCR/TesseractOCR.h>

@implementation RNTextDetector


- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

// name the module the same as the ObjC implementation module name, ie RNTextDetector - see https://facebook.github.io/react-native/docs/native-modules-ios
RCT_EXPORT_MODULE()  

static NSString *const detectionNoResultsMessage = @"Something went wrong";

// expose method detectFromUri to RN
RCT_REMAP_METHOD(detectFromUri, detectFromUri:(NSString *)imagePath resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    if (!imagePath) {
        resolve(@NO);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        VNDetectTextRectanglesRequest *textReq = [VNDetectTextRectanglesRequest new];
        NSDictionary *d = [[NSDictionary alloc] init];

        NSLog(@"\n\nImage path in native code: %@ --\n", imagePath);
        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: imagePath]];
    //    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
        NSLog(@"\n\nloaded image data\n");
        if (!imageData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                resolve(@NO);
            });
            return;
        }

        UIImage *image = [UIImage imageWithData:imageData];
        NSLog(@"\n\ncreated image\n");

        if (!image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                resolve(@NO);
            });
            return;
        }
        
        VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithData:imageData options:d];

        NSError *error;
        [handler performRequests:@[textReq] error:&error];
        if (error || !textReq.results || textReq.results.count == 0) {
            NSString *errorString = error ? error.localizedDescription : detectionNoResultsMessage;
            NSDictionary *pData = @{
                                    @"error": [NSMutableString stringWithFormat:@"On-Device text detection failed with error: %@", errorString],
                                    };
            // Running on background thread, don't call UIKit
            dispatch_async(dispatch_get_main_queue(), ^{
                resolve(pData);
            });
            return;
        }
        
        
        G8Tesseract *tesseract = [[G8Tesseract alloc] initWithLanguage:@"eng"];
        tesseract.delegate = self;
        [tesseract setImage:image];
        CGRect boundingBox;
        CGSize size;
        CGPoint origin;
        NSMutableArray *output = [NSMutableArray array];
        
        int cnt = 0;
        NSArray *filter = @[@"MRN", @"VIS", @"NAM", @"DOB", @"AGE", @"SEX"];
        int filterSize = [filter count];
        for(VNTextObservation *observation in textReq.results){
            if(observation && cnt < filterSize ){
                NSMutableDictionary *block = [NSMutableDictionary dictionary];
                NSMutableDictionary *bounding = [NSMutableDictionary dictionary];
                
                boundingBox = observation.boundingBox;
                size = CGSizeMake(boundingBox.size.width * image.size.width, boundingBox.size.height * image.size.height);
                origin = CGPointMake(boundingBox.origin.x * image.size.width, (1-boundingBox.origin.y)*image.size.height - size.height);
                
                tesseract.rect = CGRectMake(origin.x, origin.y, size.width, size.height);
                [tesseract recognize];
                
                bounding[@"top"] = @(origin.y);
                bounding[@"left"] = @(origin.x);
                bounding[@"width"] = @(size.width);
                bounding[@"height"] = @(size.height);
                block[@"text"] = [tesseract.recognizedText stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                block[@"bounding"] = bounding;

                NSString *first3Letters = [block[@"text"] substringToIndex:3];
                block[@"category"] = first3Letters;

                BOOL captureItem = TRUE;
//                switch([filter indexOfObject:first3Letters]) {
//                    case 1:  // VISIT
//                        captureItem = FALSE;
//                        break;
//                    case 0:  // MRN
//                    case 2:  // Name ... not used but possibility to have actual name trigger this
//                    case 3:  // DOB
//                    case 4:  // AGE
//                    case 5:  // SEX - may be combined with AGE
//                        break;
//                    default:
//                        if(cnt > 3) captureItem = FALSE;
//                        else block[@"category"] = @"NAM";
//
//                }
                if(captureItem) [output addObject:block];
            }
            cnt++;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            resolve(output);
        });
    });
    
}

@end
