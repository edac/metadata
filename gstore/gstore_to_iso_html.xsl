<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="#all"
    >

<xsl:output method="html" indent="yes" encoding="UTF-8"/>
    
    <xsl:param name="app-name" select="'RGIS'"/>
 
    <xsl:variable name="all-sources" select="/metadata/sources"/>
    <xsl:variable name="all-citations" select="/metadata/citations"/>
    <xsl:variable name="all-contacts" select="/metadata/contacts"/>
 
 <xsl:template match="/metadata">
     <html>
         <head>
             
             <style type="text/css">
                 body {
                    font-family: Verdana, Arial, Helvetica, sans-serif;
                    font-size: 10pt;
                 }
                 dl dt {
                    font-style: italic;
                    font-weight: bold;
                    color: #333;
                    padding-top: 3px;
                 }
                 dl dt span {
                    padding-left: 10px;
                    font-style: normal;
                    font-weight: normal;
                 }
                 
             </style>
             
         </head>
         <body>
             <a name="top"></a>
             <h2>
                 <xsl:value-of select="identification/title"/>
             </h2>
             <h3>
                 <xsl:value-of select="fn:concat('Metadata from the ', $app-name, ' Metadata Repository')"></xsl:value-of>
             </h3>
             
             <ul>
                 <li>
                     <a href="#identification">Identification Information</a>
                 </li>
                 <li>
                     <a href="#distribution">Distribution Information</a>
                 </li>
                 <li>
                     <a href="#sprefs">Spatial Reference Information</a>
                 </li>
                 <li>
                     <a href="#dataquality">Data Quality Information</a>
                 </li>            
                 <li> 
                     <a href="#metadata">Metadata Information</a>
                 </li>
             </ul>
             
             <xsl:variable name="identity-citation-id" select="identification/citation[@role='identify']/@ref"/>
             <xsl:variable name="identity-citation">
                 <xsl:copy-of select="$all-citations/citation[@id=$identity-citation-id]"/>
             </xsl:variable>
             
             <!-- TODO: update values to be the iso codelistvalues! -->
             <div itemscope="itemscope" itemtype="http://schema.org/Dataset">
                 <a name="identification"></a>
                 <h4>
                     Identification Information
                 </h4>
                 
                 <dl>
                     <dt>Title <span itemprop="name"><xsl:value-of select="identification/title"/></span></dt>
                     <dt>Date <span><xsl:value-of select="$identity-citation/citation/publication/pubdate/@date"/></span></dt>
                     <dt>Date Type <span>Publication</span></dt>
                 
                     <dt>Cited Responsible Party</dt>
                     <dd>
                         <xsl:apply-templates select="$identity-citation">
                             <xsl:with-param name="role" select="identification/citation[@role='identify']/@role"/>
                         </xsl:apply-templates>
                     </dd>
                     
                     <dt>Presentation Form <span><xsl:value-of select="$identity-citation/citation/geoform"/></span></dt>
                     <dt>Abstract <span itemprop="description"><xsl:value-of select="identification/abstract"/></span></dt>
                     <dt>Purpose <span><xsl:value-of select="identification/purpose"/></span></dt>
                     <xsl:if test="identification/supplinfo">
                         <dt>Supplemental Information <span><xsl:value-of select="identification/supplinfo"/></span></dt>
                     </xsl:if>
                     
                     <xsl:if test="identification/credit">
                         <dt>Data Set Credit <span><xsl:value-of select="identification/credit"/></span></dt>
                     </xsl:if>
                     
                     <dt>Status <span><xsl:value-of select="quality/progress"/></span></dt>
                     
                     <dt>Point of Contact</dt>
                     <dd>
                         <xsl:variable name="identity-ptcontac-id" select="identification/contact[@role='point-contact']/@ref"/>
                         <xsl:apply-templates select="$all-contacts/contact[@id=$identity-ptcontac-id]">
                             <xsl:with-param name="type" select="'publisher'"/>
                         </xsl:apply-templates>
                     </dd>
                     
                     <dt>Maintenance and Update Frequency <span><xsl:value-of select="quality/update"/></span></dt>
                     
                     <dt>Descriptive Keywords <span itemprop="keyword"><xsl:value-of select="identification/themes/theme/term" separator=", "/></span></dt>
                     
                     <dt>Access Constraints <span><xsl:value-of select="constraints/access[@type='data']"/></span></dt>
                     
                     <dt>Use Constraints <span><xsl:value-of select="constraints/use[@type='data']"/></span></dt>
                     <dt>Language <span>English</span></dt>
                     <dt>Topic Category <span itemprop="keyword"><xsl:value-of select="identification/isotopic"/></span></dt>
                     
                     <dt>Extent</dt>
                     <dd>
                         <dl>
                             <dt>Geographic Bounding Box</dt>
                             <dd>
                                 <dl itemprop="spatial" itemtype="http://schema.org/GeoShape">
                                     <meta itemprop="box" content="{fn:concat(spatial/west, ' ', spatial/south, ' ', spatial/east, ' ', spatial/north)}"/>
                                     <dt>West Bound <span><xsl:value-of select="spatial/west"/></span></dt>
                                     <dt>East Bound <span><xsl:value-of select="spatial/east"/></span></dt>
                                     <dt>North Bound <span><xsl:value-of select="spatial/north"/></span></dt>
                                     <dt>South Bound <span><xsl:value-of select="spatial/south"/></span></dt>
                                 </dl>
                             </dd>
                             <dt>Temporal Extent</dt>
                             <dd>
                                 <dl>
                                     <xsl:choose>
                                         <xsl:when test="identification/time/range">
                                             <dt>Beginning Position <span itemprop="temporal"><xsl:value-of select="identification/time/range/start/@date"/></span></dt>
                                             <dt>Ending Position <span itemprop="temporal"><xsl:value-of select="identification/time/range/end/@date"/></span></dt>
                                         </xsl:when>
                                         <xsl:when test="fn:count(identification/time/single) > 1">
                                             <xsl:for-each select="identification/time/single">
                                                 <dt>DateTime <span itemprop="temporal"><xsl:value-of select="@date"/></span></dt>
                                             </xsl:for-each>
                                         </xsl:when>
                                         <xsl:otherwise>
                                             <dt>DateTime <span itemprop="temporal"><xsl:value-of select="identification/time/single/@date"/></span></dt>
                                         </xsl:otherwise>
                                     </xsl:choose>
                                 </dl>
                             </dd>
                         </dl>
                     </dd>
                 </dl>

                 <a href="#top">Back to Top</a>
             </div>
             
             <div>
                 <a name="distribution"></a>
                 <h4>
                     Distribution Information
                 </h4>
                 
                 <xsl:for-each select="distribution/distributor">
                     <xsl:variable name="dist-contact-id" select="contact[@role='distributor']/@ref"/>
                     
                     <dl itemprop="distribution" itemscope="itemscope" itemtype="http://schema.org/DataDownload">
                         <dt>Distributor</dt>
                         <dd>
                             <xsl:apply-templates select="$all-contacts/contact[@id=$dist-contact-id]"/>
                         </dd>
                         
                         <dt>Transfer Options</dt>
                         <dd>
                             <xsl:for-each select="downloads/download">
                                 <meta itemprop="contentUrl" content="{link}"></meta>
                                 <dt>Online Resource <span><a href="{link}"><xsl:value-of select="type"/></a></span></dt>
                             </xsl:for-each>
                         </dd>

                     </dl>
                 </xsl:for-each>
                 
                 <a href="#top">Back to Top</a>
             </div>
             
             
             <div>
                 <a name="sprefs"></a>
                 <h4>
                     Spatial Reference Information
                 </h4>
                 <dl>
                     <dt>Spatial References</dt>
                     <dd>
                         <dl>
                             <xsl:for-each select="spatial/sprefs/spref">
                                 <dt>Spatial Reference <span><xsl:value-of select="title"/></span></dt>
                                 <dd>
                                     <dl>
                                         <dt>Online Reference <span><a href="{onlineref}"><xsl:value-of select="fn:concat(authority, ':', code)"/></a></span></dt>
                                     </dl>
                                 </dd>
                             </xsl:for-each>    
                         </dl>
                     </dd>
                     
                     <dt>Indirect Spatial Reference <span itemprop="spatialCoverage"><xsl:value-of select="spatial/indspref"/></span></dt>
                     
                     <xsl:if test="spatial/vector">
                         <dt>Geometric Object Type <span><xsl:value-of select="spatial/vector/sdts/@type"/></span></dt>
                         <dt>Geometric Object Count <span><xsl:value-of select="spatial/vector/sdts/@features"/></span></dt>
                     </xsl:if>
                     
                     <xsl:if test="spatial/raster">
                         <dt>Row Count <span><xsl:value-of select="spatial/raster/rows"/></span></dt>
                         <dt>Column Count <span><xsl:value-of select="spatial/raster/columns"/></span></dt>
                         <dt>Vertical Count <span><xsl:value-of select="spatial/raster/verticals"/></span></dt>
                     </xsl:if>
                 </dl>
                 
                 <a href="#top">Back to Top</a>
             </div>

             <div>
                 <a name="dataquality"></a>
                 <h4>
                     Data Quality Information
                 </h4>
                 
                 <dl>
                     <xsl:if test="quality/qual[@type='attribute']">
                         <xsl:for-each select="quality/qual[@type='attribute']">
                             <dt>Attribute Accuracy Report</dt>
                             <dd>
                                 <dl>
                                     <dt>Report <span><xsl:value-of select="report"/></span></dt>
                                     
                                     <!-- TODO: handle multiple values! -->
                                     <dt>Quantitative Attribute Accuracy Assessment</dt>
                                     <dd>
                                         <dl>
                                             <dt>Attribute Accuracy Value <span><xsl:value-of select="quantitative/value"/></span></dt>
                                             <dt>Attribute Accuracy Explanation <span><xsl:value-of select="quantitative/explanation"/></span></dt>
                                         </dl>
                                     </dd>
                                 </dl>
                             </dd>
                         </xsl:for-each>
                         
                     </xsl:if>
                     <xsl:if test="quality/qual[@type='horizontal']">
                         <xsl:for-each select="quality/qual[@type='horizontal']">
                             <dt>Horizontal Positional Accuracy Report</dt>
                             <dd>
                                 <dl>
                                     <dt>Report <span><xsl:value-of select="report"/></span></dt>

                                     <!-- TODO: handle multiple values! -->
                                     <dt>Quantitative Horizontal Positional Accuracy Assessment</dt>
                                     <dd>
                                         <dl>
                                             <dt>Horizontal Positional Accuracy Value <span><xsl:value-of select="quantitative/value"/></span></dt>
                                             <dt>Horizontal Positional Accuracy Explanation <span><xsl:value-of select="quantitative/explanation"/></span></dt>
                                         </dl>
                                     </dd>
                                 </dl>
                             </dd>
                         </xsl:for-each>
                     </xsl:if>
                     <xsl:if test="quality/qual[@type='vertical']">
                         <xsl:for-each select="quality/qual[@type='vertical']">
                             <dt>Vertical Positional Accuracy Report</dt>
                             <dd>
                                 <dl>
                                     <dt>Report <span><xsl:value-of select="report"/></span></dt>
                                     
                                     <!-- TODO: handle multiple values! -->
                                     <dt>Quantitative Vertical Positional Accuracy Assessment</dt>
                                     <dd>
                                         <dl>
                                             <dt>Vertical Positional Accuracy Value <span><xsl:value-of select="quantitative/value"/></span></dt>
                  
                                             <dt>Vertical Positional Accuracy Explanation <span><xsl:value-of select="quantitative/explanation"/></span></dt>
                                         </dl>
                                     </dd>
                                 </dl>
                             </dd>
                         </xsl:for-each>
                     </xsl:if>
                     
                     <xsl:if test="quality/logical">
                         <dt>Logical Consistency Report <span><xsl:value-of select="quality/logical"/></span></dt>
                     </xsl:if>
                     
                     <xsl:if test="quality/completeness">
                         <dt>Completeness Report <span><xsl:value-of select="quality/completeness"/></span></dt>
                     </xsl:if>
                     
                     <dt>Lineage</dt>
                     <dd>
                         <dl>
                             <xsl:for-each select="sources/source[@type='lineage']">
                               <dt>Source Information</dt>
                               <dd>
                                   <dl>
                                       <dt>Source Citation</dt>
                                       <dd>
                                           
                                       </dd>
                                       
                                       <dt>Source Scale Denominator <span><xsl:value-of select="scale"/></span></dt>
                                       
                                       <dt>Type of Source Media <span><xsl:value-of select="type"/></span></dt>
                                       
                                       <dt>Source Time Period of Content</dt>
                                       <dd>
                                           <dl>
                                               <xsl:choose>
                                                   <xsl:when test="srcdate/range">
                                                       <dt>Beginning Position <span><xsl:value-of select="srcdate/range/start/@date"/></span></dt>
                                                       <dt>Ending Position <span><xsl:value-of select="srcdate/range/end/@date"/></span></dt>
                                                   </xsl:when>
                                                   <xsl:when test="fn:count(srcdate/single) > 1">
                                                       <xsl:for-each select="srcdate/single">
                                                           <dt>DateTime <span><xsl:value-of select="@date"/></span></dt>
                                                       </xsl:for-each>
                                                   </xsl:when>
                                                   <xsl:otherwise>
                                                       <dt>DateTime <span><xsl:value-of select="srcdate/single/@date"/></span></dt>
                                                   </xsl:otherwise>
                                               </xsl:choose>
                                               
                                               <dt>Source Currentness Reference <span><xsl:value-of select="current"></xsl:value-of></span></dt>
                                           </dl>
                                       </dd>
                                       
                                       <dt>Source Citation Abbreviation <span><xsl:value-of select="alias"/></span></dt>
                                       
                                       <dt>Source Contribution <span><xsl:value-of select="contribution"/></span></dt>
                                   </dl>
                               </dd>
                             </xsl:for-each>
                             
                             <xsl:for-each select="lineage/step">
                                 <dt>Process Step</dt>
                                 <dd>
                                     <dl>
                                         <dt>Process Description <span><xsl:value-of select="description"/></span></dt>
                                         
                                         <xsl:for-each select="source[@type='used']">
                                             <xsl:variable name="srcalias-id" select="@ref"/>
                                             <xsl:variable name="srcalias" select="$all-sources/source[@id=$srcalias-id]/alias"/>
                                             <dt>Source Used Citation Abbreviation <span><xsl:value-of select="$srcalias"/></span></dt>
                                         </xsl:for-each>
                                         
                                         <dt>Process Date <span><xsl:value-of select="rundate/@date"/></span></dt>
                                         
                                         <dt>Process Time <span><xsl:value-of select="rundate/@time"/></span></dt>
   
                                         <dt>Process Contact</dt>
                                         <dd>
                                             <xsl:variable name="proc-contact-id" select="contact[@role='responsible-party']/@ref"/>
                                             <xsl:apply-templates select="$all-contacts/contact[@id=$proc-contact-id]">
                                                 <xsl:with-param name="type" select="'responsibleParty'"/>
                                             </xsl:apply-templates>
                                         </dd>
                                     </dl>
                                 </dd>
                             </xsl:for-each>
                             
                             <xsl:if test="quality/cloud">
                                 <dt>Cloud Cover <span><xsl:value-of select="quality/cloud"/></span></dt>
                             </xsl:if>
                         </dl>
                     </dd>
                 </dl>
                 
                 <a href="#top">Back to Top</a>
             </div>
             
             <div>
                 <a name="metadata"></a>
                 <h4>
                     Metadata Reference Information
                 </h4>
                 
                 <dl>
                     <dt>File Identifier <span><xsl:value-of select="identification/@identifier"/></span></dt>
                     <dt>Metadata Language <span>English</span></dt>
                     <dt>Hierarchy Level <span>Dataset</span></dt>
                     <dt>Date Stamp <span><xsl:value-of select="metadata/pubdate/@date"/></span></dt>
                     <dt>Metadata Standard Name <span>ISO 19115:2003</span></dt>
                     <dt>Metadata Standard Version <span>1.0</span></dt>
                     <dt>Metadata Contact</dt>
                     <dd>
                         <xsl:variable name="metadata-contact-id" select="metadata/contact/@ref"/>
                         <xsl:apply-templates select="$all-contacts/contact[@id=$metadata-contact-id]"></xsl:apply-templates>
                     </dd>
                 </dl>
                 
                 <a href="#top">Back to Top</a>
             </div>
             
             
         </body>
     </html>
 </xsl:template>
 
 <xsl:template match="contact">
     <xsl:param name="type"/>
     <dl>
         <xsl:if test="$type='publisher'">
             <xsl:attribute name="itemprop" select="'publisher'"/>
             <xsl:attribute name="itemscope" select="'itemscope'"/>
             <xsl:attribute name="itemtype" select="'http://schema.org/Organization'"/>
         </xsl:if>
         <dt>Individual Name <span><xsl:value-of select="person/name"/></span></dt>
         <dt>Organization Name <span itemprop="name"><xsl:value-of select="organization/name"/></span></dt>
         <dt>Position Name <span><xsl:value-of select="position"/></span></dt>
         <dt>Role <span>Point of contact</span></dt>
         <dt>Voice <span><xsl:value-of select="voice"/></span></dt>
         <dt>Facsimile <span><xsl:value-of select="fax"/></span></dt>
         <xsl:for-each select="address">
             <dt>Address</dt>
             <dd>
                 <dl>
                     <xsl:for-each select="addr">
                         <dt>Delivery Point <span><xsl:value-of select="."/></span></dt>
                     </xsl:for-each>
                     <dt>City <span><xsl:value-of select="city"/></span></dt>
                     <dt>Administrative Area <span><xsl:value-of select="state"/></span></dt>
                     <dt>Postal Code <span><xsl:value-of select="postal"/></span></dt>
                     <dt>Country <span><xsl:value-of select="country"/></span></dt>
                 </dl>
             </dd>
         </xsl:for-each>
         <dt>Electronic Mail Address <span itemprop="email"><xsl:value-of select="email"/></span></dt>
     </dl>
 </xsl:template>
 <xsl:template match="citation">
     <xsl:param name="role"></xsl:param>
     <dt>Organization Name <span><xsl:value-of select="origin"/></span></dt>
     <dt>Role <span><xsl:value-of select="$role"/></span></dt>
     <!--<dl>
         <dt>Citation Information</dt>
         <dd>
             <dl>
                 <dt>Organization Name <span><xsl:value-of select="origin"/></span></dt>
                 <!-\-<dt>Publication Date <span><xsl:value-of select="publication/pubdate/@date"/></span></dt>
                 <dt>Publication Time <span><xsl:value-of select="publication/pubdate/@time"/></span></dt>-\->
                 <!-\-<dt>Title <span><xsl:value-of select="title"/></span></dt>
                 <dt>Geospatial Data Presentation Form <span><xsl:value-of select="geoform"/></span></dt>
                 <dt>Publication Information</dt>
                 <dd>
                     <dl>
                         <dt>Publication Place <span><xsl:value-of select="publication/place"/></span></dt>
                         <dt>Publisher <span><xsl:value-of select="publication/publisher"/></span></dt>
                     </dl>
                 </dd>-\->
                 <!-\-<dt>Other Citation Details</dt>
                 <dd></dd>
                 -\->
                 <!-\-<xsl:for-each select="onlink">
                     <dt>Online Linkage <span><xsl:value-of select="."/></span></dt>
                 </xsl:for-each>
                 
                 <dt>Larger Work Citation</dt>
                 <dd></dd>-\->
             </dl>
         </dd>
     </dl>-->
 </xsl:template>
</xsl:stylesheet>