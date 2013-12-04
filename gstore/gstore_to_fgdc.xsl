<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="#all"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <!--<xsl:param name="dataset-identifier" select="fn:tokenize(fn:substring-before(fn:base-uri(.), '.xml'), '/')[last()]"></xsl:param>-->
    
    <xsl:variable name="all-sources" select="/metadata/sources"></xsl:variable>
    <xsl:variable name="all-citations" select="/metadata/citations"></xsl:variable>
    <xsl:variable name="all-contacts" select="/metadata/contacts"></xsl:variable>
    
    <!-- TODO: check the original standard - if it's iso run with a minimum viable fgdc structure
         or include a param to run mvp vs full (to avoid some of the things we can't identify from the metadata (and won't be able to))
    -->
    
    <!-- TODO: check all of the time transforms -->
    <xsl:template match="/metadata">
        <metadata>
            <!-- add the xsd for validation -->
            <xsl:choose>
                <xsl:when test="identification/@identifier and spatial/raster">
                    <xsl:attribute name="xsi:noNamespaceSchemaLocation" select="'http://www.ngdc.noaa.gov/metadata/published/xsd/ngdcSchema/schema.xsd'"></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="xsi:noNamespaceSchemaLocation" select="'http://www.fgdc.gov/metadata/fgdc-std-001-1998.xsd'"></xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>    
            <idinfo>
                <xsl:if test="spatial/raster">
                    <datsetid><xsl:value-of select="identification/@identifier"/></datsetid>
                </xsl:if>
                
                <xsl:variable name="identity-citation-id" select="identification/citation[@role='identify']/@ref"/>
                <xsl:variable name="identity-citation">
                    <xsl:copy-of select="$all-citations/citation[@id=$identity-citation-id]"></xsl:copy-of>
                </xsl:variable>
                <citation>
                    <citeinfo>
                        <xsl:apply-templates select="$identity-citation"></xsl:apply-templates>
                        <xsl:if test="identification/citation[@role='identify']/citation[@role='larger-work']">
                            <xsl:variable name="lworkcit-citation-id" select="identification/citation[@role='identify']/citation[@role='larger-work']/@ref"/>
                            <xsl:variable name="lworkcit-citation">
                                <xsl:copy-of select="$all-citations/citation[@id=$lworkcit-citation-id]"></xsl:copy-of>
                            </xsl:variable>
                            <lworkcit>
                                <citeinfo>
                                    <xsl:apply-templates select="$lworkcit-citation"></xsl:apply-templates>
                                </citeinfo>
                            </lworkcit>
                        </xsl:if>
                    </citeinfo>
                </citation>
                
                <descript>
                    <xsl:if test="identification/abstract">
                        <abstract><xsl:value-of select="identification/abstract"/></abstract>
                    </xsl:if>
                    <xsl:if test="identification/purpose">
                        <purpose><xsl:value-of select="identification/purpose"/></purpose>
                    </xsl:if>
                    <xsl:if test="identification/supplinfo">
                        <supplinf><xsl:value-of select="identification/supplinfo"/></supplinf>
                    </xsl:if>
                </descript>
                
                <timeperd>
                    <timeinfo>
                       <xsl:choose>
                           <xsl:when test="identification/time/range">
                               <rngdates>
                                   <begdate><xsl:value-of select="fn:replace(identification/time/range/start/@date, '-', '')"/></begdate>
                                   <xsl:if test="identification/time/range/start/@time">
                                       <begtime><xsl:value-of select="fn:replace(identification/time/range/start/@time, ':', '')"/></begtime>
                                   </xsl:if>
                                   <enddate><xsl:value-of select="fn:replace(identification/time/range/end/@date, '-', '')"/></enddate>
                                   <xsl:if test="identification/time/range/end/@time">
                                       <endtime><xsl:value-of select="fn:replace(identification/time/range/end/@time, ':', '')"/></endtime>
                                   </xsl:if>
                               </rngdates>
                           </xsl:when>
                           <xsl:when test="fn:count(identification/time/single) > 1">
                               <mdattim>
                                   <xsl:for-each select="identification/time/single">
                                       <sngdate>
                                           <caldate><xsl:value-of select="fn:replace(@date, '-', '')"/></caldate>
                                           <xsl:if test="@time">
                                               <time><xsl:value-of select="fn:replace(@time, ':', '')"/></time>
                                           </xsl:if>
                                       </sngdate>
                                   </xsl:for-each>
                               </mdattim>
                           </xsl:when>
                           <xsl:when test="fn:count(identification/time/single) = 1">
                               <sngdate>
                                   <caldate><xsl:value-of select="fn:replace(identification/time/single/@date, '-', '')"/></caldate>
                                   <xsl:if test="identification/time/single/@time">
                                       <time><xsl:value-of select="fn:replace(identification/time/single/@time, ':', '')"/></time>
                                   </xsl:if>
                               </sngdate>
                           </xsl:when>
                       </xsl:choose>
                    </timeinfo>
                    <current><xsl:value-of select="identification/time/current"/></current>
                </timeperd>
                
                <status>
                    <progress>
                        <xsl:value-of>
                            <xsl:choose>
                                <xsl:when test="quality/progress[fn:normalize-space(text()) = 'completed' or fn:normalize-space(text()) = 'Complete']">
                                    <xsl:value-of select="'Complete'"/>
                                </xsl:when>
                                <xsl:when test="quality/progress[fn:normalize-space(text()) = 'onGoing' or fn:normalize-space(text()) = 'In work']">
                                    <xsl:value-of select="'In work'"/>
                                </xsl:when>
                                <xsl:when test="quality/progress[fn:normalize-space(text()) = 'planned' or fn:normalize-space(text()) = 'Planned']">
                                    <xsl:value-of select="'Planned'"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:value-of>
                    </progress>
                    <update><xsl:value-of select="quality/update"/></update>
                </status>
                
                <spdom>
                    <bounding>
                        <westbc><xsl:value-of select="spatial/west"/></westbc>
                        <eastbc><xsl:value-of select="spatial/east"/></eastbc>
                        <northbc><xsl:value-of select="spatial/north"/></northbc>
                        <southbc><xsl:value-of select="spatial/south"/></southbc>
                    </bounding>
                </spdom>
                
                <keywords>
                    <xsl:if test="identification/isotopic">
                        <theme>
                            <themekt>ISO 19115 Topic Categories</themekt>
                            <themekey><xsl:value-of select="identification/isotopic"/></themekey>
                        </theme>
                    </xsl:if>
                    <xsl:if test="identification/themes">
                        <xsl:for-each select="identification/themes/theme">
                            <theme>
                                <themekt><xsl:value-of select="@thesaurus"/></themekt>
                                <xsl:for-each select="term">
                                    <themekey><xsl:value-of select="."/></themekey>
                                </xsl:for-each>
                            </theme>
                        </xsl:for-each>
                    </xsl:if>
                    
                    <!-- to maintain everything we know about a dataset, insert the epsg codes here -->
                    <xsl:if test="spatial/sprefs/spref[code!='Unknown']">
                        <place>
                            <placekt>Spatial Reference System Identifiers</placekt>
                            <xsl:for-each select="spatial/sprefs/spref[code!='Unknown']">
                                <placekey><xsl:value-of select="fn:concat(authority, ':', code)"/></placekey>
                            </xsl:for-each>
                        </place>
                    </xsl:if>
                    
                    <xsl:if test="identification/places">
                        <xsl:for-each select="identification/places/place">
                            <place>
                                <placekt><xsl:value-of select="@thesaurus"/></placekt>
                                <xsl:for-each select="term">
                                    <placekey><xsl:value-of select="."/></placekey>
                                </xsl:for-each>
                            </place>
                        </xsl:for-each>
                    </xsl:if>
                    <xsl:if test="identification/temporals">
                        <xsl:for-each select="identification/temporals/temporal">
                            <temporal>
                                <tempkt><xsl:value-of select="@thesaurus"/></tempkt>
                                <xsl:for-each select="term">
                                    <tempkey><xsl:value-of select="."/></tempkey>
                                </xsl:for-each>
                            </temporal>
                        </xsl:for-each>
                    </xsl:if>
                </keywords>
                
                <xsl:choose>
                    <xsl:when test="constraints/access[@type='data' and @code='otherRestrictions'] and constraints/other[@type='data' and fn:contains(text(), 'Access Constraints: ')]">
                        <accconst><xsl:value-of select="constraints/other[@type='data']"/></accconst>
                    </xsl:when>
                    <xsl:otherwise>
                        <accconst><xsl:value-of select="constraints/access[@type='data']"/></accconst>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="constraints/use[@type='data' and @code='otherRestrictions'] and constraints/other[@type='data' and fn:contains(text(), 'Use Constraints: ')]">
                        <useconst><xsl:value-of select="constraints/other[@type='data']"/></useconst>
                    </xsl:when>
                    <xsl:otherwise>
                        <useconst><xsl:value-of select="constraints/use[@type='data']"/></useconst>
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:variable name="identity-ptcontac-id" select="identification/contact[@role='point-contact']/@ref"/>
                
                <xsl:if test="$all-contacts/contact[@id=$identity-ptcontac-id]">
                    <ptcontac>
                        <xsl:apply-templates select="$all-contacts/contact[@id=$identity-ptcontac-id]"></xsl:apply-templates>
                    </ptcontac>
                </xsl:if>
                
                <xsl:if test="identification/browse">
                    <browse>
                        <xsl:if test="identification/browse/filename">
                            <browsen><xsl:value-of select="identification/browse/filename"/></browsen>
                        </xsl:if>
                        <xsl:if test="identification/browse/description">
                            <browsed><xsl:value-of select="identification/browse/description"/></browsed>
                        </xsl:if>
                        <xsl:if test="identification/browse/filetype">
                            <browset><xsl:value-of select="identification/browse/filetype"/></browset>
                        </xsl:if>
                    </browse>
                </xsl:if>
                
                <xsl:if test="identification/credit">
                    <datacred><xsl:value-of select="identification/credit"/></datacred>
                </xsl:if>
                
                <xsl:if test="identification/native">
                    <native><xsl:value-of select="identification/native"/></native>
                </xsl:if>
                
                <xsl:if test="identification/citation[@role='crossref']">
                    <xsl:for-each select="identification/citation[@role='crossref']">
                        <xsl:variable name="crossref-citation-id" select="@ref"/>
                        <xsl:variable name="crossref-citation">
                            <xsl:copy-of select="$all-citations/citation[@id=$crossref-citation-id]"></xsl:copy-of>
                        </xsl:variable>
                        <crossref>
                            <citeinfo>
                                <xsl:apply-templates select="$crossref-citation"></xsl:apply-templates>
                            </citeinfo>
                        </crossref>
                    </xsl:for-each>
                </xsl:if>
            </idinfo>
            
            <xsl:if test="quality/qual or quality/logical or quality/completeness or lineage/step">
                <dataqual>
                    <xsl:if test="quality/qual[@type='attribute']">
                        <xsl:for-each select="quality/qual[@type='attribute']">
                            <attracc>
                                <attraccr>
                                    <xsl:value-of select="report"/>
                                </attraccr>
                                <xsl:if test="quantitative">
                                    <xsl:for-each select="quantitative">
                                        <qattracc>
                                            <xsl:if test="value">
                                                <attraccv><xsl:value-of select="value"/></attraccv>
                                            </xsl:if>
                                            <xsl:if test="explanation">
                                                <attracce><xsl:value-of select="explanation"/></attracce>
                                            </xsl:if>
                                        </qattracc>
                                    </xsl:for-each>
                                </xsl:if>
                            </attracc>
                        </xsl:for-each>
                    </xsl:if>
                    <xsl:if test="quality/logical">
                        <logic><xsl:value-of select="quality/logical"/></logic>   
                    </xsl:if>
                    <xsl:if test="quality/completeness">
                        <complete><xsl:value-of select="quality/completeness"/></complete>   
                    </xsl:if>
                    <xsl:if test="quality/qual[@type='horizontal'] or quality/qual[@type='vertical']">
                        <posacc>
                            <xsl:if test="quality/qual[@type='horizontal']">
                                <xsl:for-each select="quality/qual[@type='horizontal']">
                                    <horizpa>
                                        <xsl:if test="report">
                                            <horizpar><xsl:value-of select="report"/></horizpar>
                                        </xsl:if>
                                        <xsl:if test="quantitative">
                                            <xsl:for-each select="quantitative">
                                                <qhorizpa>
                                                    <xsl:if test="value">
                                                        <horizpav><xsl:value-of select="value"/></horizpav>
                                                    </xsl:if>
                                                    <xsl:if test="explanation">
                                                        <horizpae><xsl:value-of select="explanation"/></horizpae>
                                                    </xsl:if>
                                                </qhorizpa>
                                            </xsl:for-each>
                                        </xsl:if>
                                    </horizpa>
                                </xsl:for-each>
                            </xsl:if>
                            <xsl:if test="quality/qual[@type='vertical']">
                                <xsl:for-each select="quality/qual[@type='vertical']">
                                    <vertacc>
                                        <xsl:if test="report">
                                            <vertaccr><xsl:value-of select="report"/></vertaccr>
                                        </xsl:if>
                                        <xsl:if test="quantitative">
                                            <xsl:for-each select="quantitative">
                                                <qvertpa>
                                                    <xsl:if test="value">
                                                        <vertaccv><xsl:value-of select="value"/></vertaccv>
                                                    </xsl:if>
                                                    <xsl:if test="explanation">
                                                        <vertacce><xsl:value-of select="explanation"/></vertacce>
                                                    </xsl:if>
                                                </qvertpa>
                                            </xsl:for-each>
                                        </xsl:if>
                                    </vertacc>
                                </xsl:for-each>
                            </xsl:if>
                        </posacc>
                    </xsl:if>
                    
                    <xsl:if test="lineage/step">
                        <lineage>
                            <xsl:for-each select="$all-sources/source[@type='lineage']">
                                <xsl:apply-templates select="."></xsl:apply-templates>
                            </xsl:for-each>
                            <xsl:for-each select="lineage/step">
                                <procstep>
                                    <procdesc><xsl:value-of select="description"/></procdesc>
                                    
                                    <xsl:if test="source[@type='used']">
                                        <xsl:for-each select="source[@type='used']">
                                            <xsl:variable name="srcalias-id" select="@ref"/>
                                            <xsl:variable name="srcalias" select="$all-sources/source[@id=$srcalias-id]/alias"/>
                                            <srcused><xsl:value-of select="$srcalias"/></srcused>
                                        </xsl:for-each>
                                    </xsl:if>
                                    
                                    <procdate><xsl:value-of select="fn:replace(rundate/@date, '-', '')"/></procdate>
                                    <xsl:if test="rundate/@time">
                                        <proctime><xsl:value-of select="fn:replace(rundate/@time, ':', '')"/></proctime>
                                    </xsl:if>
                                    
                                    <xsl:if test="source[@type='prod']">
                                        <xsl:for-each select="source[@type='prod']">
                                            <xsl:variable name="srcalias-id" select="@ref"/>
                                            <xsl:variable name="srcalias" select="$all-sources/source[@id=$srcalias-id]/alias"/>
                                            <srcprod><xsl:value-of select="$srcalias"/></srcprod>
                                        </xsl:for-each>
                                    </xsl:if>
                                    
                                    <xsl:if test="contact">
                                        <xsl:variable name="step-contact-id" select="contact/@ref"/>
                                        <proccont>
                                            <xsl:apply-templates select="$all-contacts/contact[@id=$step-contact-id]"/>
                                        </proccont>
                                    </xsl:if>
                                </procstep>
                            </xsl:for-each>
                        </lineage>
                    </xsl:if>
                </dataqual>
            </xsl:if>
           
            
            <xsl:if test="spatial/indspref or spatial/raster or spatial/vector">
                <spdoinfo>
                    <xsl:if test="spatial/indspref">
                        <indspref><xsl:value-of select="spatial/indspref"/></indspref>
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="spatial/raster">
                            <direct>Raster</direct>
                            <rastinfo>
                                <cvaltype><xsl:value-of select="spatial/raster/@cval"/></cvaltype>
                                <rasttype><xsl:value-of select="spatial/raster/@type"/></rasttype>
                                <xsl:if test="spatial/raster/rows/text()">
                                    <rowcount><xsl:value-of select="spatial/raster/rows"/></rowcount>
                                </xsl:if>
                                <xsl:if test="spatial/raster/columns/text()">
                                    <colcount><xsl:value-of select="spatial/raster/columns"/></colcount>
                                </xsl:if>
                                <xsl:if test="spatial/raster/verticals/text()">
                                    <vrtcount><xsl:value-of select="spatial/raster/verticals"/></vrtcount>
                                </xsl:if>
                            </rastinfo>
                        </xsl:when>
                        <xsl:when test="spatial/vector">
                            <direct>Vector</direct>
                            <ptvctinf>
                                <xsl:for-each select="spatial/vector/sdts">
                                     <sdtsterm>
                                         <sdtstype><xsl:value-of select="@type"/></sdtstype>
                                         <xsl:if test="@features and fn:lower-case(@features) != 'unknown'">
                                             <ptvctcnt><xsl:value-of select="@features"/></ptvctcnt>
                                         </xsl:if>
                                     </sdtsterm>
                                </xsl:for-each>
                            </ptvctinf>
                        </xsl:when>
                    </xsl:choose>
                </spdoinfo>
            </xsl:if>
            
            <!-- one can only hope the representation is correctly structured fgdc at this point, but here we are -->
            <xsl:if test="spatial/sprefs/representation[@type='fgdc']">
                <xsl:choose>
                    <xsl:when test="spatial/sprefs/representation[@type='fgdc']/def/gridsys">
                        <!-- gridsys of some description -->
                        <xsl:variable name="prj" select="spatial/sprefs/representation[@type='fgdc']/def[gridsys]"/>
                        <spref>
                            <horizsys>
                                <planar>
                                    <xsl:copy-of select="$prj/gridsys"/>
                                    <xsl:choose>
                                        <xsl:when test="$prj/planci">
                                            <xsl:copy-of select="$prj/planci"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <planci>
                                                <plance>row and column</plance>
                                                <coordrep>
                                                    <absres>1</absres>
                                                    <ordres>1</ordres>
                                                </coordrep>
                                                <plandu>meters</plandu>
                                            </planci>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </planar>
                                <xsl:copy-of select="$prj/geodetic"/>
                            </horizsys>
                        </spref>
                    </xsl:when>
                    <xsl:when test="spatial/sprefs/representation[@type='fgdc']/def/mapproj">
                        <!-- projection of some description -->
                        <xsl:variable name="prj" select="spatial/sprefs/representation[@type='fgdc']/def[mapproj]"/>
                        <spref>
                            <horizsys>
                                <planar>
                                    <xsl:copy-of select="$prj/mapproj"/>
                                    <xsl:choose>
                                        <xsl:when test="$prj/planci">
                                            <xsl:copy-of select="$prj/planci"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <planci>
                                                <plance>row and column</plance>
                                                <coordrep>
                                                    <absres>1</absres>
                                                    <ordres>1</ordres>
                                                </coordrep>
                                                <plandu>meters</plandu>
                                            </planci>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </planar>
                                <xsl:copy-of select="$prj/geodetic"/>
                            </horizsys>
                        </spref>
                    </xsl:when>
                    <xsl:when test="spatial/sprefs/representation[@type='fgdc']/def/geodetic and not(spatial/sprefs/representation[@type='fgdc']/def/gridsys or spatial/sprefs/representation[@type='fgdc']/def/mapproj)">
                        <!-- just the datum -->
                        <spref>
                            <horizsys>
                                <xsl:choose>
                                    <xsl:when test="spatial/sprefs/representation[@type='fgdc']/def/geograph">
                                        <xsl:copy-of select="spatial/sprefs/representation[@type='fgdc']/def/geograph"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <geograph>
                                            <latres>0.00000001</latres>
                                            <longres>0.00000001</longres>
                                            <geogunit>Decimal degrees</geogunit>
                                        </geograph>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:copy-of select="spatial/sprefs/representation[@type='fgdc']/def/geodetic"/>
                            </horizsys>
                        </spref>
                    </xsl:when>
                </xsl:choose>
            </xsl:if>

            <xsl:if test="attributes">
                <eainfo>
                    <xsl:if test="attributes/entity">
                        <detailed>
                            <xsl:if test="attributes/entity">
                                <enttyp>
                                    <enttypl><xsl:value-of select="attributes/entity[1]/label"/></enttypl>
                                    <enttypd><xsl:value-of select="attributes/entity[1]/description"/></enttypd>
                                    <enttypds><xsl:value-of select="attributes/entity[1]/source"/></enttypds>
                                </enttyp>
                            </xsl:if>
                            <xsl:for-each select="attributes/attr">
                                <attr>
                                    <attrlabl><xsl:value-of select="label"/></attrlabl>
                                    <attrdef><xsl:value-of select="definition"/></attrdef>
                                    <attrdefs><xsl:value-of select="source"/></attrdefs>
                                    <attrdomv>
                                        <xsl:choose>
                                            <xsl:when test="unrepresented">
                                                <udom><xsl:value-of select="unrepresented/description"/></udom>
                                            </xsl:when>
                                            <xsl:when test="codeset">
                                                <codesetd>
                                                    <codesetn><xsl:value-of select="codeset/name"/></codesetn>
                                                    <codesets><xsl:value-of select="codeset/source"/></codesets>
                                                </codesetd>
                                            </xsl:when>
                                            <xsl:when test="range">
                                                <rdom>
                                                    <rdommin><xsl:value-of select="range/min"/></rdommin>
                                                    <rdommax><xsl:value-of select="range/max"/></rdommax>
                                                    <xsl:if test="range/units and range/units/text() != ''">
                                                        <attrunit><xsl:value-of select="range/units"/></attrunit>
                                                    </xsl:if>
                                                    
                                                </rdom>
                                            </xsl:when>
                                            <xsl:when test="enumerated">
                                                <xsl:for-each select="enumerated/value">
                                                    <edom>
                                                        <edomv><xsl:value-of select="enum"/></edomv>
                                                        <edomvd><xsl:value-of select="description"/></edomvd>
                                                        <edomvds><xsl:value-of select="source"/></edomvds>
                                                    </edom>
                                                </xsl:for-each>
                                            </xsl:when>
                                        </xsl:choose>
                                    </attrdomv>
                                </attr>
                            </xsl:for-each>
                        </detailed>
                        <xsl:if test="count(attributes/entity) > 1">
                            <xsl:for-each select="attributes/entity[position() > 1]">
                                <detailed>
                                    <enttyp>
                                        <enttypl><xsl:value-of select="label"/></enttypl>
                                        <enttypd><xsl:value-of select="description"/></enttypd>
                                        <enttypds><xsl:value-of select="source"/></enttypds>
                                    </enttyp>
                                </detailed>
                            </xsl:for-each>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="attributes/overview or attributes/eacite">
                        <overview>
                            <eaover><xsl:value-of select="attributes/overview"/></eaover>
                            <xsl:if test="attributes/eacite">
                                <eadetcit><xsl:value-of select="attributes/eacite"/></eadetcit>
                            </xsl:if>
                        </overview>
                    </xsl:if>
                </eainfo>
            </xsl:if>
            
            <xsl:if test="distribution">
                <xsl:for-each select="distribution/distributor">
                    <distinfo>
                        <distrib>
                            <xsl:variable name="dist-contact-id" select="contact[@role='distributor']/@ref"/>
                            
                            <xsl:apply-templates select="$all-contacts/contact[@id=$dist-contact-id]"></xsl:apply-templates>
                        </distrib>
                        <xsl:if test="description">
                            <resdesc>
                                <xsl:value-of select="description"/>
                            </resdesc>
                        </xsl:if>
                        <xsl:if test="liability">
                            <distliab>
                                <xsl:value-of select="liability"/>
                            </distliab>
                        </xsl:if>
                        <xsl:for-each select="downloads/download">
                            <stdorder>
                                <digform>
                                    <digtinfo>
                                        <formname>
                                            <xsl:value-of select="type"/>
                                        </formname>
                                        <xsl:if test="size">
                                            <transize>
                                                <xsl:value-of select="size"/>
                                            </transize>
                                        </xsl:if>
                                    </digtinfo>
                                    <digtopt>
                                        <onlinopt>
                                            <computer>
                                                <networka>
                                                    <networkr>
                                                        <xsl:value-of select="link"/>
                                                    </networkr>
                                                </networka>
                                            </computer>
                                            <xsl:if test="../../access">
                                                <accinstr>
                                                    <xsl:value-of select="../../access"/>
                                                </accinstr>
                                            </xsl:if>
                                        </onlinopt>
                                    </digtopt>
                                </digform>
                                <xsl:if test="../../fees">
                                    <fees>
                                        <xsl:value-of select="../../fees"/>
                                    </fees>
                                </xsl:if>
                                <xsl:if test="../../ordering">
                                    <ordering>
                                        <xsl:value-of select="../../ordering"/>
                                    </ordering>
                                </xsl:if>
                            </stdorder>
                        </xsl:for-each>
                        <xsl:if test="instructions">
                            <custom>
                                <xsl:value-of select="instructions"/>
                            </custom>
                        </xsl:if>
                        <xsl:if test="prereqs">
                            <techpreq>
                                <xsl:value-of select="prereqs"/>
                            </techpreq>
                        </xsl:if>
                    </distinfo>
                </xsl:for-each>
            </xsl:if>
            
            <metainfo>
                <metd><xsl:value-of select="fn:replace(metadata/pubdate/@date, '-', '')"/></metd>
                <metc>
                    <xsl:variable name="metadata-contact-id" select="metadata/contact/@ref"/>
                    <xsl:apply-templates select="$all-contacts/contact[@id=$metadata-contact-id]"></xsl:apply-templates>
                </metc>
                <metstdn>FGDC Content Standards for Digital Geospatial Metadata</metstdn>
                <metstdv>FGDC-STD-001-1998</metstdv>
                
                <mettc>local time</mettc>
                <xsl:if test="identification/@identifier and spatial/raster">
                    <metextns>
                        <onlink>http://www.fgdc.gov/standards/projects/FGDC-standards-projects/csdgm_rs_ex/MetadataRemoteSensingExtens.pdf</onlink>
                        <metprof>Extensions for Remote Sensing Metadata, FGDC-STD-012-2002</metprof>
                    </metextns>
                </xsl:if>
            </metainfo>
        </metadata>
    </xsl:template>
    <xsl:template match="contact">
        <cntinfo>
            <xsl:if test="organization">
                <cntorgp>
                    <xsl:if test="organization/name and organization/name/text()">
                        <cntorg><xsl:value-of select="organization/name"/></cntorg> 
                    </xsl:if>
                    <xsl:if test="organization/person and organization/person/text()">
                        <cntper><xsl:value-of select="organization/person"/></cntper>
                    </xsl:if>
                </cntorgp>
            </xsl:if>
            <xsl:if test="person">
                <cntperp>
                    <xsl:if test="person/name and person/name/text()">
                        <cntper><xsl:value-of select="person/name"/></cntper>
                    </xsl:if>
                    <xsl:if test="person/organization and person/organization/text()">
                        <cntorg><xsl:value-of select="person/organization"/></cntorg>
                    </xsl:if>
                </cntperp>
            </xsl:if>
            <xsl:if test="position">
                <cntpos><xsl:value-of select="position"/></cntpos>
            </xsl:if>
            <xsl:if test="address">
                <cntaddr>
                    <addrtype><xsl:value-of select="address/@type"/></addrtype>
                    <xsl:for-each select="address/addr">
                        <address><xsl:value-of select="."/></address>
                    </xsl:for-each>
                    <city><xsl:value-of select="address/city"/></city>
                    <state><xsl:value-of select="address/state"/></state>
                    <postal><xsl:value-of select="address/postal"/></postal>
                    <xsl:if test="address/country and address/country/text()">
                        <country><xsl:value-of select="address/country"/></country>
                    </xsl:if>
                </cntaddr>
            </xsl:if>
            <xsl:if test="voice">
                <cntvoice><xsl:value-of select="voice"/></cntvoice>
            </xsl:if>
            <xsl:if test="fax">
                <cntfax><xsl:value-of select="fax"/></cntfax>
            </xsl:if>
            <xsl:if test="email">
                <cntemail><xsl:value-of select="email"/></cntemail>
            </xsl:if>
            <xsl:if test="hours">
                <hours><xsl:value-of select="hours"/></hours>
            </xsl:if>
            <xsl:if test="instructions">
                <cntinst><xsl:value-of select="instructions"/></cntinst>
            </xsl:if>
        </cntinfo>
    </xsl:template>
    <xsl:template match="source">
        <srcinfo>
            
            <xsl:variable name="src-citation-id" select="citation/@ref">
            </xsl:variable>
            <srccite>
                <citeinfo>
                    <xsl:apply-templates select="$all-citations/citation[@id=$src-citation-id]"></xsl:apply-templates>
                </citeinfo>
            </srccite>
            <xsl:if test="scale">
                <srcscale><xsl:value-of select="scale"/></srcscale>
            </xsl:if>
            <xsl:if test="type">
                <typesrc><xsl:value-of select="type"/></typesrc>
            </xsl:if>
            <xsl:if test="srcdate">
                <srctime>
                    <timeinfo>
                        <xsl:choose>
                            <xsl:when test="srcdate/range">
                                <rngdates>
                                    <begdate><xsl:value-of select="fn:replace(srcdate/range/start/@date, '-', '')"/></begdate>
                                    <enddate><xsl:value-of select="fn:replace(srcdate/range/end/@date, '-', '')"/></enddate>
                                </rngdates>
                            </xsl:when> 
                            <xsl:when test="count(srcdate/single) > 1">
                                <mdattim>
                                  <xsl:for-each select="srcdate/single">
                                      <sngdate>
                                          <caldate>
                                              <xsl:value-of select="fn:replace(@date, '-', '')"/>
                                          </caldate>
                                          <xsl:if test="@time">
                                              <time>
                                                  <xsl:value-of select="fn:replace(@time, ':', '')"/>
                                              </time>
                                          </xsl:if>
                                      </sngdate>
                                  </xsl:for-each>
                                </mdattim>
                            </xsl:when>
                            <xsl:when test="count(srcdate/single) = 1">
                                <sngdate>
                                    <caldate><xsl:value-of select="fn:replace(srcdate/single/@date, '-', '')"/></caldate>
                                </sngdate>
                            </xsl:when>
                        </xsl:choose>
                    </timeinfo>
                    <srccurr><xsl:value-of select="current"/></srccurr>
                </srctime>
            </xsl:if>
            <xsl:if test="alias">
                <srccitea><xsl:value-of select="alias"/></srccitea>
            </xsl:if>
            <xsl:if test="contribution">
                <srccontr><xsl:value-of select="contribution"/></srccontr>
            </xsl:if>
        </srcinfo>
    </xsl:template>
    <xsl:template match="citation">
            <origin><xsl:value-of select="origin"/></origin>
            <pubdate>
                <xsl:choose>
                    <xsl:when test="fn:contains(fn:lower-case(publication/pubdate/@date), 'unpublished')">
                        <xsl:value-of select="'Unpublished material'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="fn:replace(publication/pubdate/@date, '-', '')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </pubdate>
            <title><xsl:value-of select="title"/></title>
            <xsl:if test="edition">
                <edition><xsl:value-of select="edition"/></edition>
            </xsl:if>
            <xsl:if test="geoform">
                <geoform><xsl:value-of select="geoform"/></geoform>
            </xsl:if>
            <xsl:if test="serial">
                <serinfo>
                    <xsl:if test="serial/name">
                        <sername><xsl:value-of select="serial/name"/></sername>
                    </xsl:if>
                    <xsl:if test="serial/issue">
                        <issue><xsl:value-of select="serial/issue"/></issue>
                    </xsl:if>
                </serinfo>
            </xsl:if>
            <xsl:if test="publication/place or publication/publisher">
                <pubinfo>
                    <xsl:if test="publication/place">
                        <pubplace><xsl:value-of select="publication/place"/></pubplace>
                    </xsl:if>
                    <xsl:if test="publication/publisher">
                        <publish><xsl:value-of select="publication/publisher"/></publish>
                    </xsl:if>
                </pubinfo>
            </xsl:if>
        <xsl:if test="othercit">
            <othercit><xsl:value-of select="othercit"/></othercit>
        </xsl:if>
            <xsl:for-each select="onlink">
                <onlink><xsl:value-of select="."/></onlink>
            </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>