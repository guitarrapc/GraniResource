Grani_TopShelf
============

Just a minor copy of MSFT_Archive, to prevent opening exsisting file stream for comparison.

Resource Information
----

Name | FriendlyName | ModuleName 
-----|-----|-----
Grani_Archive | cArchive | GraniResource

Test Status
----

Depends on MSDT test result. No test will be done.

Intellisense
----

Same as MSFT_Archive

Sample
----

Same as MSFT_Archive

Tips
----

**Why this crazy resource exists?**

As MSFT_Archive resource try to retrieve file stream handler, it will fail for TEST when file already been used. cArchive resource just change this section from File Stream to File Path, so TEST never retrieve file handle and avoid exception.
