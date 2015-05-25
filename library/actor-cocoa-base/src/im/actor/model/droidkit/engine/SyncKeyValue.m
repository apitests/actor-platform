//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/ex3ndr/Develop/actor-model/library/actor-cocoa-base/build/java/im/actor/model/droidkit/engine/SyncKeyValue.java
//


#include "IOSPrimitiveArray.h"
#include "J2ObjC_source.h"
#include "im/actor/model/droidkit/engine/KeyValueStorage.h"
#include "im/actor/model/droidkit/engine/SyncKeyValue.h"

@interface DKSyncKeyValue () {
 @public
  id<DKKeyValueStorage> storage_;
}

@end

J2OBJC_FIELD_SETTER(DKSyncKeyValue, storage_, id<DKKeyValueStorage>)

@implementation DKSyncKeyValue

- (instancetype)initWithDKKeyValueStorage:(id<DKKeyValueStorage>)storage {
  DKSyncKeyValue_initWithDKKeyValueStorage_(self, storage);
  return self;
}

- (void)putWithLong:(jlong)key
      withByteArray:(IOSByteArray *)data {
  @synchronized(self) {
    [((id<DKKeyValueStorage>) nil_chk(storage_)) addOrUpdateItemWithKey:key withData:data];
  }
}

- (void)delete__WithLong:(jlong)key {
  @synchronized(self) {
    [((id<DKKeyValueStorage>) nil_chk(storage_)) removeItemWithKey:key];
  }
}

- (IOSByteArray *)getWithLong:(jlong)key {
  @synchronized(self) {
    return [((id<DKKeyValueStorage>) nil_chk(storage_)) getValueWithKey:key];
  }
}

@end

void DKSyncKeyValue_initWithDKKeyValueStorage_(DKSyncKeyValue *self, id<DKKeyValueStorage> storage) {
  (void) NSObject_init(self);
  self->storage_ = storage;
}

DKSyncKeyValue *new_DKSyncKeyValue_initWithDKKeyValueStorage_(id<DKKeyValueStorage> storage) {
  DKSyncKeyValue *self = [DKSyncKeyValue alloc];
  DKSyncKeyValue_initWithDKKeyValueStorage_(self, storage);
  return self;
}

J2OBJC_CLASS_TYPE_LITERAL_SOURCE(DKSyncKeyValue)
