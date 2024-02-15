/*
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A PersistentCacheIndexManager, for configuring persistent cache indexes used for local query
 * execution.
 */
NS_SWIFT_NAME(PersistentCacheIndexManager)
@interface FIRPersistentCacheIndexManager : NSObject

/** :nodoc: */
- (instancetype)init
    __attribute__((unavailable("FIRPersistentCacheIndexManager cannot be created directly.")));

/**
 * Enables the SDK to create persistent cache indexes automatically for local query execution when
 * the SDK believes cache indexes can improve performance.
 *
 * This feature is disabled by default.
 */
- (void)enableIndexAutoCreation NS_SWIFT_NAME(enableIndexAutoCreation());

/**
 * Stops creating persistent cache indexes automatically for local query execution. The indexes
 * which have been created by calling `enableIndexAutoCreation` still take effect.
 */
- (void)disableIndexAutoCreation NS_SWIFT_NAME(disableIndexAutoCreation());

/**
 * Removes all persistent cache indexes. Please note this function also deletes indexes generated by
 * [[FIRFirestore firestore] setIndexConfigurationFromJSON] and [[FIRFirestore firestore]
 * setIndexConfigurationFromStream], which are deprecated.
 */
- (void)deleteAllIndexes NS_SWIFT_NAME(deleteAllIndexes());

@end

NS_ASSUME_NONNULL_END
