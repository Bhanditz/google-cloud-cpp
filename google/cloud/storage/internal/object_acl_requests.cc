// Copyright 2018 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include "google/cloud/storage/internal/object_acl_requests.h"
#include "google/cloud/storage/internal/nljson.h"
#include <iostream>

namespace google {
namespace cloud {
namespace storage {
inline namespace STORAGE_CLIENT_NS {
namespace internal {
std::ostream& operator<<(std::ostream& os, CreateObjectAclRequest const& r) {
  os << "CreateObjectAclRequest={bucket_name=" << r.bucket_name()
     << ", object_name=" << r.object_name() << ", entity=" << r.entity()
     << ", role=" << r.role();
  r.DumpParameters(os, ", ");
  return os << "}";
}

std::ostream& operator<<(std::ostream& os, UpdateObjectAclRequest const& r) {
  os << "UpdateObjectAclRequest={bucket_name=" << r.bucket_name()
     << ", object_name=" << r.object_name() << ", entity=" << r.entity()
     << ", role=" << r.role();
  r.DumpParameters(os, ", ");
  return os << "}";
}

std::ostream& operator<<(std::ostream& os, ObjectAclRequest const& r) {
  os << "ObjectAclRequest={bucket_name=" << r.bucket_name()
     << ", object_name=" << r.object_name() << ", entity=" << r.entity();
  r.DumpParameters(os, ", ");
  return os << "}";
}

}  // namespace internal
}  // namespace STORAGE_CLIENT_NS
}  // namespace storage
}  // namespace cloud
}  // namespace google
