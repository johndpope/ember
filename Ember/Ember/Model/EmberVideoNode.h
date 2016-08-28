/* This file provided by Facebook is for non-commercial testing and evaluation
 * purposes only.  Facebook reserves all rights not expressly granted.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <AsyncDisplayKit/ASVideoNode.h>
#import <UIKit/UIKit.h>
#import "EmberSnapShot.h"
@import Firebase;

@protocol OrgImageInVideoNodeClickedDelegate;

@interface EmberVideoNode : ASCellNode

- (instancetype)initWithEvent:(EmberSnapShot *)snapShot;

@property (nonatomic, weak) id<OrgImageInVideoNodeClickedDelegate> delegate;
@property(strong, nonatomic) FIRDatabaseReference *ref;

-(ASVideoNode*) getVideoNode;
-(void)setPlaceholderImage:(UIImage *)img;
-(void)setPlaceholderEnabled:(BOOL)placeholderEnabled;
-(ASTextNode *)getTextNode;
-(ASTextNode *)getDateTextNode;


@end

@protocol OrgImageInVideoNodeClickedDelegate <NSObject>

- (void)bounceVideoOrgImageClicked:(NSString*)orgId;

@end