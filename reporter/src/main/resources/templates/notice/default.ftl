[#--
    Copyright (C) 2020 HERE Europe B.V.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    SPDX-License-Identifier: Apache-2.0
    License-Filename: LICENSE
--]
[#--
    The notice file generated by this template consists of the following sections:

    * The licenses and associated copyrights for all projects merged into a single list.
    * The archived license files, licenses and associated copyrights for dependencies listed by package.

    Excluded projects and packages are ignored.
--]
[#assign noticeCategoryName = "include-in-notice-file"]
[#-- Add the licenses of the projects. --]
[#assign hasNoticeProjectLicenses = false]
[#--
    Merge the licenses and copyrights of all projects into a single list. The default LicenseView.ALL is used because
    projects cannot have a concluded license (compare with the handling of packages below).
--]
[#assign mergedLicenses = helper.mergeLicenses(projects)]
[#-- Filter for those licenses that are categorized to be included in notice files. --]
[#assign filteredLicenses = helper.filterForCategory(mergedLicenses, noticeCategoryName)]
[#list filteredLicenses as resolvedLicense]
    [#assign licenseName = resolvedLicense.license.simpleLicense()]
    [#assign licenseText = licenseTextProvider.getLicenseText(licenseName)!]
    [#if !licenseText?has_content][#continue][/#if]
    [#if !hasNoticeProjectLicenses]
This software includes external packages and source code.
The applicable license information is listed below:

----
        [#assign hasNoticeProjectLicenses = true]
    [#else]
  --
    [/#if]
    [#assign copyrights = resolvedLicense.getCopyrights()]
    [#if copyrights?has_content]

    [/#if]
${copyrights?join("\n", "", "\n")}
${licenseText}
    [#assign exceptionName = resolvedLicense.license.exception()!]
    [#assign exceptionText = licenseTextProvider.getLicenseText(exceptionName)!]
    [#if exceptionText?has_content]
${exceptionText}
    [/#if]
[/#list]
[#-- Add the licenses of all packages. --]
[#if packages?has_content]
    [#if hasNoticeProjectLicenses]
----

    [/#if]
This software depends on external packages and source code.
The applicable license information is listed below:

[/#if]
[#list packages?filter(p -> !p.excluded) as package]
    [#assign hasNoticePackageLicenses = false]
    [#-- List the content of archived license files and associated copyrights. --]
    [#list package.licenseFiles.files as licenseFile]
        [#if !hasNoticePackageLicenses]
----

Package: [#if package.id.namespace?has_content]${package.id.namespace}:[/#if]${package.id.name}:${package.id.version}
            [#assign hasNoticePackageLicenses = true]
        [/#if]

This package contains the file ${licenseFile.path} with the following contents:

${licenseFile.text}
        [#assign copyrights = licenseFile.getCopyrights()]
        [#if copyrights?has_content]
The following copyright holder information relates to the license(s) above:

${copyrights?join("\n", "")}
        [/#if]
    [/#list]
    [#--
        Filter the licenses of the package using LicenseView.CONCLUDED_OR_DECLARED_AND_DETECTED. This is the default
        view which ignores declared and detected licenses if a license conclusion for the package was made. If
        copyrights were detected for a concluded license those statements are kept. Also filter all licenses that
        are configured not to be included in notice files, and filter all licenses that are contained in the license
        files already printed above.
    --]
    [#assign resolvedLicenses = helper.filterForCategory(
        LicenseView.CONCLUDED_OR_DECLARED_AND_DETECTED.filter(package.licensesNotInLicenseFiles()),
        noticeCategoryName
    )]
    [#assign isFirst = true]
    [#list resolvedLicenses as resolvedLicense]
        [#assign licenseName = resolvedLicense.license.simpleLicense()]
        [#assign licenseText = licenseTextProvider.getLicenseText(licenseName)!]
        [#if !licenseText?has_content][#continue][/#if]
        [#if isFirst]
            [#if !hasNoticePackageLicenses]
----

Package: [#if package.id.namespace?has_content]${package.id.namespace}:[/#if]${package.id.name}:${package.id.version}
                [#assign hasNoticePackageLicenses = true]
            [/#if]

The following copyrights and licenses were found in the source code of this package:
            [#assign isFirst = false]
        [#else]
  --
        [/#if]
        [#assign copyrights = resolvedLicense.getCopyrights()]
        [#if copyrights?has_content]

        [/#if]
${copyrights?join("\n", "", "\n")}
${licenseText}
        [#assign exceptionName = resolvedLicense.license.exception()!]
        [#assign exceptionText = licenseTextProvider.getLicenseText(exceptionName)!]
        [#if exceptionText?has_content]
${exceptionText}
        [/#if]
    [/#list]
[/#list]
