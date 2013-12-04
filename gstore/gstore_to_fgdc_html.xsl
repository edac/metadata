<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="#all"
    >

<xsl:output method="html" indent="yes" encoding="UTF-8"/>
    
    <xsl:param name="app-name" select="'RGIS'"></xsl:param>
 
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
                 
                 div dl {
                    margin: 20px;
                 }
                 
             </style>
             
         </head>
         <body>
             <a name="top"></a>
             <h2>
                 <xsl:value-of select="identification/title"/>
             </h2>
             <h3>
                 <xsl:value-of select="fn:concat('Metadata from the ', $app-name, ' Metadata Repository')"/>
             </h3>
             
             <ul>
                 <li>
                     <a href="#identification">Identification Information</a>
                 </li>
                 <li>
                     <a href="#dataquality">Data Quality Information</a>
                 </li>
                 <li>
                     <a href="#spdoinfo">Spatial Data Organization Information</a>
                 </li>
                 <li>
                     <a href="#sprefs">Spatial Reference Information</a>
                 </li>
                 <xsl:if test="attributes">
                     <li>
                         <a href="#attributes">Entity and Attribute Information</a>
                     </li>
                 </xsl:if>
                 <li>
                     <a href="#distribution">Distribution Information</a>
                 </li>
                 <li>
                     <a href="#metadata">Metadata Reference Information</a>
                 </li>
             </ul>
             
             <div itemscope="itemscope" itemtype="http://schema.org/Dataset">
              <div>
                  <a name="identification"></a>
                  <h4>
                      Identification Information
                  </h4>
                  <dl>
                      <dt>Citation</dt>
                      <dd>
                          <xsl:variable name="identity-citation-id" select="identification/citation[@role='identify']/@ref"/>
                          <xsl:variable name="identity-citation">
                              <xsl:copy-of select="$all-citations/citation[@id=$identity-citation-id]"/>
                          </xsl:variable>
                          
                          <!-- check for the larger work citation -->
                          <xsl:variable name="lwork">
                              <xsl:if test="identification/citation[@role='identify']/citation[@role='larger-work']">
                                  <xsl:variable name="lwork-citation-id" select="identification/citation[@role='identify']/citation[@role='larger-work']/@ref"/>
                   
                                  <xsl:copy-of select="$all-citations/citation[@id=$lwork-citation-id]"/>
                              </xsl:if>
                          </xsl:variable>
                          
                          <xsl:apply-templates select="$identity-citation">
                              <xsl:with-param name="lwork-citation" select="$lwork"/>
                          </xsl:apply-templates>
                      </dd>
                      
                      <dt>Description</dt>
                      <dd>
                          <dl>
                              <dt>Abstract <span itemprop="description"><xsl:value-of select="identification/abstract"/></span></dt>
                              <dt>Purpose <span><xsl:value-of select="identification/purpose"/></span></dt>
                              
                              <xsl:if test="identification/supplinfo">
                                  <dt>Supplemental Information <span><xsl:value-of select="identification/supplinfo"/></span></dt>
                              </xsl:if>
                          </dl>
                      </dd>
                      
                      <dt>Time Period of Content</dt>
                      <dd>
                          <dl>
                              <xsl:choose>
                                  <xsl:when test="identification/time/range">
                                      <dt>Range of Dates/Times</dt>
                                      <dd>
                                          <dl>
                                              <dt>Beginning Date <span itemprop="temporal"><xsl:value-of select="identification/time/range/start/@date"/></span></dt>
                                              <xsl:if test="identification/time/range/start/@time">
                                                  <dt>Beginning Time <span itemprop="temporal"><xsl:value-of select="identification/time/range/start/@time"/></span></dt>
                                              </xsl:if>
                                              <dt>Ending Date <span itemprop="temporal"><xsl:value-of select="identification/time/range/end/@date"/></span></dt>
                                              <xsl:if test="identification/time/range/end/@time">
                                                  <dt>Ending Time <span itemprop="temporal"><xsl:value-of select="identification/time/range/end/@time"/></span></dt>
                                              </xsl:if>
                                          </dl>
                                      </dd>
                                  </xsl:when>
                                  <xsl:when test="fn:count(identification/time/single) > 1">
                                      <dt>Multiple Dates/Times</dt>
                                      <dd>
                                          <xsl:for-each select="identification/time/single">
                                              <dl>
                                                  <dt>Single Date/Time</dt>
                                                  <dd>
                                                      <dl>
                                                          <dt>Calendar Date <span itemprop="temporal"><xsl:value-of select="@date"/></span></dt>
                                                          <xsl:if test="@time">
                                                              <dt>Time <span itemprop="temporal"><xsl:value-of select="@time"/></span></dt>
                                                          </xsl:if>
                                                      </dl>
                                                  </dd>
                                              </dl>
                                          </xsl:for-each>
                                      </dd>
                                  </xsl:when>
                                  <xsl:when test="fn:count(identification/time/single) = 1">
                                      <dt>Single Date/Time</dt>
                                      <dd>
                                          <dl>
                                              <dt>Calendar Date <span itemprop="temporal"><xsl:value-of select="identification/time/single/@date"/></span></dt>
                                              <xsl:if test="identification/time/single/@time">
                                                  <dt>Time <span itemprop="temporal"><xsl:value-of select="identification/time/single/@time"/></span></dt>
                                              </xsl:if>
                           
                                          </dl>
                                      </dd>
                                  </xsl:when>
                              </xsl:choose>
         
                              <dt>Currentness Reference <span><xsl:value-of select="identification/time/current"/></span></dt>
                          </dl>
                      </dd>
                      
                      <dt>Status</dt>
                      <dd>
                          <dl>
                              <dt>Progress <span><xsl:value-of select="quality/progress"/></span></dt>
                              <dt>Maintenance and Update Frequency <span><xsl:value-of select="quality/update"/></span></dt>
                          </dl>
                      </dd>
                      
                      <dt>Spatial Domain</dt>
                      <dd>
                          <dl>
                              <dt>Bounding Coordinates</dt>
                              <dd>
                                  <dl itemprop="spatial" itemtype="http://schema.org/GeoShape">
                                      <meta itemprop="box" content="{fn:concat(spatial/west, ' ', spatial/south, ' ', spatial/east, ' ', spatial/north)}"/>
                                      <dt>West Bounding Coordinate <span><xsl:value-of select="spatial/west"/></span></dt>
                                      <dt>East Bounding Coordinate <span><xsl:value-of select="spatial/east"/></span></dt>
                                      <dt>North Bounding Coordinate <span><xsl:value-of select="spatial/north"/></span></dt>
                                      <dt>South Bounding Coordinate <span><xsl:value-of select="spatial/south"/></span></dt>
                                  </dl>
                              </dd>
                          </dl>
                      </dd>
                      
                      <dt>Keywords</dt>
                      <dd>
                          <xsl:for-each select="identification/themes/theme">
                              <dl>
                                  <dt>Theme</dt>
                                  <dd>
                                      <dl>
                                          <dt>Thesaurus <span><xsl:value-of select="@thesaurus"/></span></dt>
                                          
                                          <xsl:for-each select="term">
                                              <dt>Keyword <span itemprop="keyword"><xsl:value-of select="."/></span></dt>
                                          </xsl:for-each>
                                      </dl>
                                  </dd>
                              </dl>
                          </xsl:for-each>
                          <xsl:if test="identification/isotopic">
                              <dl>
                                  <dt>Theme</dt>
                                  <dd>
                                      <dl>
                                          <dt>Thesaurus <span>ISO 19115 Topic Categories</span></dt>
                                          <dt>Keyword <span itemprop="keyword"><xsl:value-of select="identification/isotopic"/></span></dt>
                                      </dl>
                                  </dd>
                              </dl>
                          </xsl:if>
                          <xsl:for-each select="identification/places/place">
                              <dl>
                                  <dt>Place</dt>
                                  <dd>
                                      <dl>
                                          <dt>Thesaurus <span><xsl:value-of select="@thesaurus"/></span></dt>
                                          <xsl:for-each select="term">
                                              <dt>Keyword <span itemprop="keyword"><xsl:value-of select="."/></span></dt>
                                          </xsl:for-each>
                                      </dl>
                                  </dd>
                              </dl>
                          </xsl:for-each>
                      </dd>
                      
                      <!-- TODO: add stratums and temporal -->
                      
                      <dt>Access Constraints <span><xsl:value-of select="constraints/access[@type='data']"/></span></dt>
                      
                      <dt>Use Constraints <span><xsl:value-of select="constraints/use[@type='data']"/></span></dt>
                      
                      <dt>Point of Contact</dt>
                      <dd>
                          <xsl:variable name="identity-ptcontac-id" select="identification/contact[@role='point-contact']/@ref"/>
                          
                          <xsl:if test="$all-contacts/contact[@id=$identity-ptcontac-id]">
                              <xsl:apply-templates select="$all-contacts/contact[@id=$identity-ptcontac-id]"/>
                          </xsl:if>
                      </dd>
                      
                      <xsl:if test="identification/browse">
                          <dt>Browse Graphic</dt>
                          <dd>
                              <dl>
                                  <dt>File Name <span><xsl:value-of select="identification/browse/filename"/></span></dt>
                                  <dt>File Type <span><xsl:value-of select="identification/browse/filetype"/></span></dt>
                                  <dt>Description <span><xsl:value-of select="identification/browse/description"/></span></dt>
                              </dl>
                          </dd>
                      </xsl:if>
                      
                      <xsl:if test="identification/credit">
                          <dt>Data Set Credit <span><xsl:value-of select="identification/credit"/></span></dt>
                      </xsl:if>
                      
                      <xsl:if test="constraints/security[@type='data']">
                          <dt>Security Information</dt>
                          <dd>
                              <dl>
                                  <dt>Security Classification System <span><xsl:value-of select="constraints/security[@type='data']/classification/@system"/></span></dt>
                                  <dt>Security Classification <span><xsl:value-of select="constraints/security[@type='data']/classification"/></span></dt>
                                  <dt>Security Handling Description <span><xsl:value-of select="constraints/security[@type='data']/handling"/></span></dt>
                              </dl>
                          </dd>
                      </xsl:if>
                      
                      <xsl:if test="identification/native">
                          <dt>Native Data Set Environment <span><xsl:value-of select="identification/native"/></span></dt>
                      </xsl:if>
                      
                      <xsl:if test="identification/citation[@role='crossref']">
                          <xsl:for-each select="identification/citation[@role='crossref']">
                               <dt>Cross Reference</dt>
                               <dd>
                                   <xsl:variable name="ref" select="@ref"/>
                                   <xsl:variable name="cross-citation">
                                       <xsl:copy-of select="$all-citations/citation[@id=$ref]"/>
                                   </xsl:variable>
                                   <xsl:apply-templates select="$cross-citation"/>
                               </dd>
                          </xsl:for-each>
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
                                            <xsl:variable name="src-citation-id" select="citation/@ref"/>
                                            <xsl:variable name="src-citation">
                                                <xsl:copy-of select="$all-citations/citation[@id=$src-citation-id]"/>
                                            </xsl:variable>
                                            
                                            <xsl:apply-templates select="$src-citation"/>
                                        </dd>
                                        
                                        <dt>Source Scale Denominator <span><xsl:value-of select="scale"/></span></dt>
                                        
                                        <dt>Type of Source Media <span><xsl:value-of select="type"/></span></dt>
                                        
                                        <dt>Source Time Period of Content</dt>
                                        <dd>
                                            <dl>
                                                <xsl:choose>
                                                   <xsl:when test="identification/time/range">
                                                       <dt>Range of Dates/Times</dt>
                                                       <dd>
                                                           <dl>
                                                               <dt>Beginning Date <span><xsl:value-of select="identification/time/range/start/@date"/></span></dt>
                                                               <xsl:if test="identification/time/range/start/@time">
                                                                   <dt>Beginning Time <span><xsl:value-of select="identification/time/range/start/@time"/></span></dt>
                                                               </xsl:if>
                                                               <dt>Ending Date <span><xsl:value-of select="identification/time/range/end/@date"/></span></dt>
                                                               <xsl:if test="identification/time/range/end/@time">
                                                                   <dt>Ending Time <span><xsl:value-of select="identification/time/range/end/@time"/></span></dt>
                                                               </xsl:if>
                                                           </dl>
                                                       </dd>
                                                   </xsl:when>
                                                   <xsl:when test="fn:count(identification/time/single) > 1">
                                                       <dt>Multiple Dates/Times</dt>
                                                       <dd>
                                                           <xsl:for-each select="identification/time/single">
                                                               <dl>
                                                                   <dt>Single Date/Time</dt>
                                                                   <dd>
                                                                       <dl>
                                                                           <dt>Calendar Date <span><xsl:value-of select="@date"/></span></dt>
                                                                           <xsl:if test="@time">
                                                                               <dt>Time <span><xsl:value-of select="@time"/></span></dt>
                                                                           </xsl:if>
                                                                       </dl>
                                                                   </dd>
                                                               </dl>
                                                           </xsl:for-each>
                                                       </dd>
                                                   </xsl:when>
                                                   <xsl:when test="fn:count(identification/time/single) = 1">
                                                       <dt>Single Date/Time</dt>
                                                       <dd>
                                                           <dl>
                                                               <dt>Calendar Date <span><xsl:value-of select="identification/time/single/@date"/></span></dt>
                                                               <xsl:if test="identification/time/single/@time">
                                                                   <dt>Time <span><xsl:value-of select="identification/time/single/@time"/></span></dt>
                                                               </xsl:if>
                                                               
                                                           </dl>
                                                       </dd>
                                                   </xsl:when>
                                               </xsl:choose>
                                                <dt>Source Currentness Reference <span><xsl:value-of select="current"/></span></dt>
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
                                          
                                          <xsl:for-each select="source[@type='prod']">
                                              <xsl:variable name="srcprod-id" select="@ref"/>
                                              <xsl:variable name="srcprod" select="$all-sources/source[@id=$srcprod-id]/alias"/>
                                              <dt>Source Produced Citation Abbreviation <span><xsl:value-of select="$srcprod"/></span></dt>
                                          </xsl:for-each>
                                          
    
                                          <dt>Process Contact</dt>
                                          <dd>
                                              <xsl:variable name="src-contact-id" select="contact/@ref"/>
                                              <xsl:variable name="src-contact">
                                                  <xsl:copy-of select="$all-contacts/contact[@id=$src-contact-id]"/>
                                              </xsl:variable>
                                              
                                              <xsl:apply-templates select="$src-contact"/>
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
                  <a name="spdoinfo"></a>
                  <h4>
                      Spatial Data Organization Information
                  </h4>
                  
                  <dl>
                      <dt>Indirect Spatial Reference Method <span itemprop="spatialCoverage"><xsl:value-of select="spatial/indspref"/></span></dt>
                      
                      <xsl:if test="spatial/vector">
                          <dt>Direct Spatial Reference Method <span>Vector</span></dt>
                          
                          <dt>Point and Vector Object Information</dt>
                          <dd>
                              <dl>
                                  <xsl:for-each select="spatial/vector/sdts">
                                      <dt>SDTS Terms Description</dt>
                                      <dd>
                                          <dl>
                                              <dt>SDTS Point and Vector Object Type <span><xsl:value-of select="@type"/></span></dt>
 
                                              <dt>Point and Vector Object Count <span><xsl:value-of select="@features"/></span></dt>
                                          </dl>
                                      </dd>
                                  </xsl:for-each>
                              </dl>
                          </dd>
                      </xsl:if>
                      
                      <xsl:if test="spatial/raster">
                          <dt>Direct Spatial Reference Method <span>Raster</span></dt>
                          
                          <dt>Raster Object Information</dt>
                          <dd>
                              <dl>
                                  <dt>Raster Object Type <span><xsl:value-of select="spatial/raster/@type"/></span></dt>
                                  <dt>Row Count <span><xsl:value-of select="spatial/raster/rows"/></span></dt>
                                  <dt>Column Count <span><xsl:value-of select="spatial/raster/columns"/></span></dt>
                                  <dt>Vertical Count <span><xsl:value-of select="spatial/raster/verticals"/></span></dt>
                              </dl>
                          </dd>
                      </xsl:if>
                  </dl>
                  
                  <a href="#top">Back to Top</a>
              </div>
              <div>
                  <a name="sprefs"></a>
                  <h4>
                      Spatial Reference Information
                  </h4>
                  <dl>
                      <xsl:for-each select="spatial/sprefs/spref[@type != 'Unknown']">
                          <dt>Spatial Reference</dt>
                          <dd>
                              <dl>
                                  <dt>Name <span><xsl:value-of select="title"/></span></dt>
                                  <dt>Code <span><xsl:value-of select="fn:concat(authority, ':', code)"/></span></dt>
                                  <dt>URL <span><xsl:value-of select="onlineref"/></span></dt>
                              </dl>
                          </dd>
                          
                      </xsl:for-each>
                  </dl>
                  
                  <a href="#top">Back to Top</a>
              </div>
              <xsl:if test="attributes">
                  <div>
                      <a name="attributes"></a>
                      <h4>
                          Entity and Attribute Information
                      </h4>
                      
                      <dl>
 
                          <dt>Detailed Description</dt>
                          <dd>
                              <dl>
                                  <xsl:if test="attributes/entity">
                                      <dt>Entity Type</dt>
                                      <dd>
                                          <dl>
                                              <dt>Entity Type Label<span><xsl:value-of select="attributes/entity/label"/></span></dt>
                                              <dt>Entity Type Definition <span><xsl:value-of select="attributes/entity/description"/></span></dt>
                                              <dt>Entity Type Definition Source <span><xsl:value-of select="attributes/entity/source"/></span></dt>
                                          </dl>
                                      </dd>
                                  </xsl:if>
                                 
                                 <xsl:for-each select="attributes/attr">
                                     <dt>Attribute</dt>
                                     <dd>
                                         <dl>
                                             <dt>Attribute Label <span><xsl:value-of select="label"/></span></dt>
                                             <dt>Attribute Definition <span><xsl:value-of select="definition"/></span></dt>
                                             <dt>Attribute Definition Source <span><xsl:value-of select="source"/></span></dt>
                                             
                                             <dt>Attribute Domain Values</dt>
                                             <dd>
                                                 <xsl:choose>
                                                     <xsl:when test="codeset">
                                                         <dl>
                                                             <dt>Codeset Domain</dt>
                                                             <dd>
                                                                 <dl>
                                                                     <dt>Codeset Name <span><xsl:value-of select="codeset/name"/></span></dt>
                                                                    
                                                                     <dt>Codeset Source <span><xsl:value-of select="codeset/source"/></span></dt>
     
                                                                 </dl>
                                                             </dd>
                                                         </dl>
                                                     </xsl:when>
                                                     <xsl:when test="enumerated">
                                                         <dl>
                                                             <dt>Enumerated Domain</dt>
                                                             <dd>
                                                                 <xsl:for-each select="enumerated/value">
                                                                     <dl>
                                                                         <dt>Enumerated Domain Value <span><xsl:value-of select="enum"/></span></dt>
     
                                                                         <dt>Enumerated Domain Value Definition <span><xsl:value-of select="description"/></span></dt>
                                                                         <dt>Enumerated Domain Value Definition Source <span><xsl:value-of select="source"/></span></dt>
                                                                     </dl>
                                                                 </xsl:for-each>
                                                             </dd>
                                                         </dl>
                                                     </xsl:when>
                                                     <xsl:when test="range">
                                                         <dl>
                                                             <dt>Range Domain</dt>
                                                             <dd>
                                                                 <dl>
                                                                     <dt>Range Domain Minimum <span><xsl:value-of select="range/min"/></span></dt>
                                                                     <dt>Range Domain Maximum <span><xsl:value-of select="range/max"/></span></dt>
                                                                     <dt>Attribute Units of Measure <span><xsl:value-of select="range/units"/></span></dt>
                                                                 </dl>
                                                             </dd>
                                                         </dl>
                                                     </xsl:when>
                                                     <xsl:when test="unrepresented">
                                                         <dl>
                                                             <dt>Unrepresentable Domain <span><xsl:value-of select="unrepresented/description"/></span></dt>
                                                         </dl>
                                                     </xsl:when>
                                                 </xsl:choose>
                                                 
                                             </dd>
                                         </dl>
                                     </dd>
                                 </xsl:for-each>
                              </dl>
                          </dd>
                          
                          <xsl:if test="attributes/overview or attributes/eacite">
                              <dt>Overview Description</dt>
                              <dd>
                                  <dl>
                                      <xsl:if test="attributes/overview">
                                          <dt>Entity and Attribute Overview <span><xsl:value-of select="attributes/overview"/></span></dt>
                                      </xsl:if>
                                      <xsl:if test="attributes/eacite">
                                          <dt>Entity and Attribute Detail Citation <span><xsl:value-of select="attributes/eacite"/></span></dt>
                                      </xsl:if>
                                  </dl>
                              </dd>
                          </xsl:if>
                      </dl>
                      
                      <a href="#top">Back to Top</a>
                  </div>
              </xsl:if>
              <div>
                  <a name="distribution"></a>
                  <h4>
                      Distribution Information
                  </h4>
                  
                  <xsl:for-each select="distribution/distributor">
                      <dl>
                          <dt>Distributor</dt>
                          <dt>Resource Description <span><xsl:value-of select="description"/></span></dt>
                          <dt>Distribution Liability <span><xsl:value-of select="liability"/></span></dt>
                                                 
                          <xsl:for-each select="downloads/download">
                              <dl itemprop="distribution" itemscope="itemscope" itemtype="http://schema.org/DataDownload">
                                  <dt>Standard Order Process</dt>
                                  <dd>
                                      <dl>
                                          <dt>Digital Form</dt>
                                          <dd>
                                              <dl>
                                                  <dt>Digital Transfer Information</dt>
                                                  <dd>
                                                      <dl>
                                                          <dt>Format Name <span itemprop="description"><xsl:value-of select="type"/></span></dt>
                                                          <dt>Transfer Size <span itemprop="contentSize"><xsl:value-of select="size"/></span></dt>
                                                      </dl>
                                                  </dd>
                                                  
                                                  <dt>Digital Transfer Option</dt>
                                                  <dd>
                                                      <dl>
                                                          <dt>Online Option</dt>
                                                          <dd>
                                                              <dl>
                                                                  <dt>Computer Contact Information</dt>
                                                                  <dd>
                                                                      <dl>
                                                                          <dt>Network Address</dt>
                                                                          <dd>
                                                                              <dl>
                                                                                  <meta itemprop="contentUrl" content="{link}"></meta>
                                                                                  <dt>Network Resource Name <span><a href="{link}"><xsl:value-of select="link"/></a></span></dt>
                                                                              </dl>
                                                                          </dd>
                                                                      </dl>
                                                                  </dd>
                                                              </dl>
                                                          </dd>
                                                          
                                                          <dt>Access Instructions <span><xsl:value-of select="../../access"/></span></dt>
                                                         
                                                      </dl>
                                                  </dd>
                                              </dl>
                                          </dd>
                                      
                                          <dt>Fees <span><xsl:value-of select="../../fees"/></span></dt>
                                          
                                          <dt>Ordering Instructions <span><xsl:value-of select="../../ordering"/></span></dt>
                                      </dl>
                                  </dd>
                              </dl>
                          </xsl:for-each>
                          
                          <dt>Custom Order Process <span><xsl:value-of select="instructions"/></span></dt>
                          <dt>Technical Prerequisites <span><xsl:value-of select="prereqs"/></span></dt>
                          
                      </dl>
                  </xsl:for-each>
 
                  <a href="#top">Back to Top</a>
              </div>
              <div>
                  <a name="metadata"></a>
                  <h4>
                      Metadata Reference Information
                  </h4>
                  
                  <dl>
                      <dt>Metadata Date <span><xsl:value-of select="metadata/pubdate/@date"/></span></dt>
                      <dt>Metadata Review Date <span><xsl:value-of select="metadata/revdate/@date"/></span></dt>
                      <dt>Metadata Future Review Date <span><xsl:value-of select="metadata/frevdate/@date"/></span></dt>
                      <dt>Metadata Contact</dt>
                      <dd>
                          <xsl:variable name="metadata-contact-id" select="metadata/contact/@ref"/>
                          <xsl:apply-templates select="$all-contacts/contact[@id=$metadata-contact-id]">
                              <xsl:with-param name="type" select="'publisher'"/>
                          </xsl:apply-templates>
                      </dd>
                      <dt>Metadata Standard Name <span>FGDC Content Standards for Digital Geospatial Metadata</span></dt>
                      <dt>Metadata Standard Version <span>FGDC-STD-001-1998</span></dt>
                      <dt>Metadata Time Convention <span></span></dt>
                      <dt>Metadata Access Constraints <span><xsl:value-of select="constraints/access[@type='metadata']"/></span></dt>
                      <dt>Metadata Use Constraints <span><xsl:value-of select="constraints/use[@type='metadata']"/></span></dt>
                      <dt>Metadata Security Information</dt>
                      <dd>
                          <dl>
                              <dt>Security Classification System <span><xsl:value-of select="constraints/security[@type='metadata']/classification/@system"/></span></dt>
                              <dt>Security Classification <span><xsl:value-of select="constraints/security[@type='metadata']/classification"/></span></dt>
                              <dt>Security Handling Description <span><xsl:value-of select="constraints/security[@type='metadata']/handling"/></span></dt>
                          </dl>
                      </dd>
                      <dt>Metadata Extensions <span><xsl:value-of select="if (spdoinfo[direct='Raster']) then 'Extensions for Remote Sensing Metadata, FGDC-STD-012-2002' else ''"/></span></dt>
                  </dl>
                  
                  <a href="#top">Back to Top</a>
              </div>
             </div>
         </body>
     </html>
 </xsl:template>
 
 <xsl:template match="contact">
     <xsl:param name="type"/>
     <dl>
         <xsl:if test="$type = 'publisher'">
             <xsl:attribute name="itemprop" select="'publisher'"/>
             <xsl:attribute name="itemscope" select="'itemscope'"/>
             <xsl:attribute name="itemtype" select="'http://schema.org/Organization'"/>
         </xsl:if>
         <dt>Contact Information</dt>
         <dd>
             <dl>
                 <dt>Contact Person Primary</dt>
                 <dd>
                     <dl>
                         <dt>Contact Person <span><xsl:value-of select="person/name"/></span></dt>
                         <dt>Contact Organization <span><xsl:value-of select="person/organization"/></span></dt>
                     </dl>
                 </dd>
                 <dt>Contact Organization Primary</dt>
                 <dd>
                     <dl>
                         <dt>Contact Organization <span itemprop="name"><xsl:value-of select="organization/name"/></span></dt>
                         <dt>Contact Person <span><xsl:value-of select="organization/person"/></span></dt>
                     </dl>
                 </dd>
                 <dt>Contact Position <span><xsl:value-of select="position"/></span></dt>
                 <xsl:for-each select="address">
                     <dt>Contact Address</dt>
                     <dd>
                         <dl>
                             <dt>Address Type <span><xsl:value-of select="@type"/></span></dt>
                             <xsl:for-each select="addr">
                                 <dt>Address <span><xsl:value-of select="."/></span></dt>
                             </xsl:for-each>
                             <dt>City <span><xsl:value-of select="city"/></span></dt>
                             <dt>State or Province <span><xsl:value-of select="state"/></span></dt>
                             <dt>Postal Code <span><xsl:value-of select="postal"/></span></dt>
                             <dt>Country <span><xsl:value-of select="country"/></span></dt>
                         </dl>
                     </dd>
                 </xsl:for-each>
                 <dt>Contact Voice Telephone <span><xsl:value-of select="voice"/></span></dt>
                 <dt>Contact Facsimile Telephone <span><xsl:value-of select="fax"/></span></dt>
                 <dt>Contact Electronic Mail Address <span itemprop="email"><xsl:value-of select="email"/></span></dt>
                 <dt>Hours of Service <span><xsl:value-of select="hours"/></span></dt>
                 <dt>Contact Instructions <span><xsl:value-of select="instructions"/></span></dt>
             </dl>
         </dd>
     </dl>
 </xsl:template>
 <xsl:template match="citation">
     <xsl:param name="lwork-citation"/>
     <dl>
         <dt>Citation Information</dt>
         <dd>
             <dl>
                 <dt>Originator <span><xsl:value-of select="origin"/></span></dt>
                 <dt>Publication Date <span><xsl:value-of select="publication/pubdate/@date"/></span></dt>
                 <dt>Publication Time <span><xsl:value-of select="publication/pubdate/@time"/></span></dt>
                 <dt>Title <span itemprop="name"><xsl:value-of select="title"/></span></dt>
                 <dt>Geospatial Data Presentation Form <span><xsl:value-of select="geoform"/></span></dt>
                 <dt>Publication Information</dt>
                 <dd>
                     <dl>
                         <dt>Publication Place <span><xsl:value-of select="publication/place"/></span></dt>
                         <dt>Publisher <span><xsl:value-of select="publication/publisher"/></span></dt>
                     </dl>
                 </dd>
                 <dt>Other Citation Details <span><xsl:value-of select="othercit"/></span></dt>
                 
                 <xsl:for-each select="onlink">
                     <dt>Online Linkage <span><a href="{.}"><xsl:value-of select="."/></a></span></dt>
                 </xsl:for-each>

                 <xsl:if test="$lwork-citation">
                     <dt>Larger Work Citation</dt>
                     <dd>
                         <xsl:apply-templates select="$lwork-citation"/>
                     </dd>
                 </xsl:if>
             </dl>
         </dd>
     </dl>
 </xsl:template>
</xsl:stylesheet>