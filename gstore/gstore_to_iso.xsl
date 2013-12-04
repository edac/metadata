<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
version="2.0" xmlns:fn="http://www.w3.org/2005/xpath-functions"
xmlns:gss="http://www.isotc211.org/2005/gss"
xmlns:gts="http://www.isotc211.org/2005/gts"
xmlns:gml="http://www.opengis.net/gml/3.2"
xmlns:xlink="http://www.w3.org/1999/xlink"
xmlns:gco="http://www.isotc211.org/2005/gco"
xmlns:gmd="http://www.isotc211.org/2005/gmd"
xmlns:gmi="http://www.isotc211.org/2005/gmi"
xmlns:gmx="http://www.isotc211.org/2005/gmx"
xmlns:gsr="http://www.isotc211.org/2005/gsr"
xmlns="http://www.isotc211.org/2005/gmi"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://www.isotc211.org/2005/gmi http://www.ngdc.noaa.gov/metadata/published/xsd/schema.xsd" >
   <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <!--<xsl:param name="dataset-identifier" select="fn:tokenize(fn:substring-before(fn:base-uri(.), '.xml'), '/')[last()]"></xsl:param>-->
    <xsl:param name="fc-url" required="no"></xsl:param>
    
    <xsl:param name="app" select="'RGIS'"/>
   
   <xsl:variable name="all-sources" select="/metadata/sources"></xsl:variable>
   <xsl:variable name="all-citations" select="/metadata/citations"></xsl:variable>
   <xsl:variable name="all-contacts" select="/metadata/contacts"></xsl:variable>
   
   
    <!-- TODO: add the raster type:
        gmd:contentInfo/gmd:MD_ImageDescription
       
        (https://geo-ide.noaa.gov/wiki/index.php?title=ISO_19115_and_19115-2_CodeList_Dictionaries#MD_CoverageContentTypeCode)  
    
        with attribute definition, raster type (see codelist above for types), cloud cover
    -->
   
   <xsl:template match="/metadata">
       <gmi:MI_Metadata>
           <xsl:attribute name="xsi:schemaLocation" select="'http://www.isotc211.org/2005/gmi http://www.ngdc.noaa.gov/metadata/published/xsd/schema.xsd'"></xsl:attribute>
           <gmd:fileIdentifier>
               <gco:CharacterString>
                   <xsl:value-of select="fn:concat(fn:upper-case($app), '::', identification/@dataset, '::ISO-19115:2003')"/>
               </gco:CharacterString>
           </gmd:fileIdentifier>
           <gmd:language>
               <gco:CharacterString>eng; USA</gco:CharacterString>
           </gmd:language>
           <gmd:characterSet>
               <gmd:MD_CharacterSetCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_CharacterSetCode" 
                   codeListValue="utf8"></gmd:MD_CharacterSetCode>
           </gmd:characterSet>
           <gmd:hierarchyLevel>
               <gmd:MD_ScopeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_ScopeCode" 
                   codeListValue="{if (spatial) then 'dataset' else 'nonGeographicDataset'}"></gmd:MD_ScopeCode>
           </gmd:hierarchyLevel>
           
           <xsl:variable name="identity-ptcontac-id">
               <xsl:choose>
                   <xsl:when test="identification/contact[@role='point-contact' and contains(@ref, ' ')]">
                       <xsl:value-of select="identification/contact[@role='point-contact']/substring-before(@ref, ' ')"></xsl:value-of>
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:value-of select="identification/contact[@role='point-contact']/@ref"></xsl:value-of>
                   </xsl:otherwise>
               </xsl:choose>
           </xsl:variable>
           <gmd:contact>
               <gmd:CI_ResponsibleParty>
<!--                 generate the basic contact info bits  -->
                     <xsl:apply-templates select="$all-contacts/contact[@id=$identity-ptcontac-id]"></xsl:apply-templates>
<!--                 add the role based on the contact@role (not the contact selected from the list of all contacts)  -->
                     <gmd:role>
                         <xsl:variable name="rolecode">
                             <xsl:choose>
                                 <xsl:when test="identification/contact[@role='point-contact']">
                                     <xsl:value-of select="'pointOfContact'"></xsl:value-of>
                                 </xsl:when>
                             </xsl:choose>
                         </xsl:variable>
                         <gmd:CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                             codeListValue="{$rolecode}"><xsl:value-of select="$rolecode"></xsl:value-of></gmd:CI_RoleCode>
                     </gmd:role>
               </gmd:CI_ResponsibleParty>
           </gmd:contact>
           <gmd:dateStamp>
<!--           from the metadata timestamp    -->
               
               <xsl:variable name="met-datetime">
                   <xsl:call-template name="format-datetime">
                       <xsl:with-param name="datestring" select="metadata/pubdate/@date"/>
                       <xsl:with-param name="timestring" select="metadata/pubdate/@time"/>
                   </xsl:call-template>
               </xsl:variable>
               <xsl:choose>
                   <xsl:when test="fn:contains($met-datetime, 'unknown') or fn:contains($met-datetime, 'present')">
                       <xsl:attribute name="gco:nilReason" select="'unknown'"/>
                   </xsl:when>
                   <xsl:when test="fn:contains($met-datetime, 'T') and fn:contains($met-datetime, ':')">
                       <gco:Date>
                           <xsl:value-of select="fn:substring-before($met-datetime, 'T')"/>
                       </gco:Date>
                   </xsl:when>
                   <xsl:otherwise>
                       <gco:Date>
                           <xsl:value-of select="$met-datetime"/>
                       </gco:Date>
                   </xsl:otherwise>
               </xsl:choose>               
           </gmd:dateStamp>
           <gmd:metadataStandardName>
               <gco:CharacterString>
                   <xsl:choose>
                       <xsl:when test="identification/@dataset">
                           <xsl:value-of select="'ISO 19115-2 Geographic Information - Metadata - Part 2: Extensions for Imagery and Gridded Data'"></xsl:value-of>
                       </xsl:when>
                       <xsl:otherwise>
                           <xsl:value-of select="'ISO 19115 Geographic Information - Metadata'"></xsl:value-of>
                       </xsl:otherwise>
                   </xsl:choose>
               </gco:CharacterString>
           </gmd:metadataStandardName>
           <gmd:metadataStandardVersion>
               <gco:CharacterString>
                   <xsl:choose>
                       <xsl:when test="identification/@dataset">
                           <xsl:value-of select="'ISO 19115-2:2009(E)'"></xsl:value-of>
                       </xsl:when>
                       <xsl:otherwise>
                           <xsl:value-of select="'ISO 19115'"></xsl:value-of>
                       </xsl:otherwise>
                   </xsl:choose>
               </gco:CharacterString>
           </gmd:metadataStandardVersion>
       
           <gmd:dataSetURI>
               <gco:CharacterString><xsl:value-of select="identification/@dataset"/></gco:CharacterString>
           </gmd:dataSetURI>
       
           <xsl:if test="spatial/raster">
               <gmd:spatialRepresentationInfo>
                   <gmd:MD_GridSpatialRepresentation>
                       <gmd:numberOfDimensions>
                           <gco:Integer><xsl:value-of select="fn:count(spatial/raster/verticals | spatial/raster/rows | spatial/raster/columns)"/></gco:Integer>
                       </gmd:numberOfDimensions>
                       <gmd:axisDimensionProperties>
                           <gmd:MD_Dimension>
                               <gmd:dimensionName>
                                   <gmd:MD_DimensionNameTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_DimensionNameTypeCode"
                                       codeListValue="row">row</gmd:MD_DimensionNameTypeCode>
                               </gmd:dimensionName>
                               <xsl:choose>
                                   <xsl:when test="spatial/raster/rows/text()">
                                       <gmd:dimensionSize>
                                           <gco:Integer><xsl:value-of select="spatial/raster/rows"/></gco:Integer>
                                       </gmd:dimensionSize>
                                   </xsl:when>
                                   <xsl:otherwise>
                                       <gmd:dimensionSize/>
                                   </xsl:otherwise>
                               </xsl:choose>
                           </gmd:MD_Dimension>
                       </gmd:axisDimensionProperties>
                       <gmd:axisDimensionProperties>
                           <gmd:MD_Dimension>
                               <gmd:dimensionName>
                                   <gmd:MD_DimensionNameTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_DimensionNameTypeCode"
                                       codeListValue="column">column</gmd:MD_DimensionNameTypeCode>
                               </gmd:dimensionName>
                               <xsl:choose>
                                   <xsl:when test="spatial/raster/columns/text()">
                                       <gmd:dimensionSize>
                                           <gco:Integer><xsl:value-of select="spatial/raster/columns"/></gco:Integer>
                                       </gmd:dimensionSize>
                                   </xsl:when>
                                   <xsl:otherwise>
                                       <gmd:dimensionSize/>
                                   </xsl:otherwise>
                               </xsl:choose>
                           </gmd:MD_Dimension>
                       </gmd:axisDimensionProperties>
                       <xsl:if test="spatial/raster/verticals">
                           <gmd:axisDimensionProperties>
                               <gmd:MD_Dimension>
                                   <gmd:dimensionName>
                                       <gmd:MD_DimensionNameTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_DimensionNameTypeCode"
                                           codeListValue="vertical">vertical</gmd:MD_DimensionNameTypeCode>
                                   </gmd:dimensionName>
                                   <xsl:choose>
                                       <xsl:when test="spatial/raster/verticals/text()">
                                           <gmd:dimensionSize>
                                               <gco:Integer><xsl:value-of select="spatial/raster/verticals"/></gco:Integer>
                                           </gmd:dimensionSize>
                                       </xsl:when>
                                       <xsl:otherwise>
                                           <gmd:dimensionSize/>
                                       </xsl:otherwise>
                                   </xsl:choose>
                               </gmd:MD_Dimension>
                           </gmd:axisDimensionProperties>
                       </xsl:if>
                       <gmd:cellGeometry>
                           <!-- TODO: add more options? -->
                           <xsl:variable name="cell-geom">
                               <xsl:choose>
                                   <xsl:when test="spatial/raster/@type='Pixel'">
                                       <xsl:value-of select="'point'"/>
                                   </xsl:when>
                                   <xsl:otherwise>
                                       <xsl:value-of select="'unknown'"/>
                                   </xsl:otherwise>
                               </xsl:choose>
                           </xsl:variable>
                           <gmd:MD_CellGeometryCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_CellGeometryCode"
                               codeListValue="{$cell-geom}"></gmd:MD_CellGeometryCode>
                       </gmd:cellGeometry>
                       <gmd:transformationParameterAvailability gco:nilReason="unknown"/>
                   </gmd:MD_GridSpatialRepresentation>
               </gmd:spatialRepresentationInfo>
           </xsl:if>
           <xsl:if test="spatial/vector">
               <gmd:spatialRepresentationInfo>
                   <gmd:MD_VectorSpatialRepresentation>
                        <xsl:for-each select="spatial/vector/sdts">
                           <gmd:geometricObjects>
                               <gmd:MD_GeometricObjects>
                                   <gmd:geometricObjectType>
                                       <gmd:MD_GeometricObjectTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_GeometricObjectTypeCode"
                                           codeListValue="{fn:lower-case(@type)}"/>
                                   </gmd:geometricObjectType>
                                   <gmd:geometricObjectCount>
                                       <xsl:choose>
                                           <xsl:when test="@features = 'Unknown'">
                                               <xsl:attribute name="gco:nilReason" select="'unknown'"></xsl:attribute>
                                           </xsl:when>
                                           <xsl:otherwise>
                                               <gco:Integer><xsl:value-of select="@features"/></gco:Integer>
                                           </xsl:otherwise>
                                       </xsl:choose>
                                   </gmd:geometricObjectCount>
                               </gmd:MD_GeometricObjects>
                           </gmd:geometricObjects>
                        </xsl:for-each>
                   </gmd:MD_VectorSpatialRepresentation>
               </gmd:spatialRepresentationInfo>
           </xsl:if>
       
           <xsl:if test="spatial/indspref">
               <gmd:referenceSystemInfo>
                   <gmd:MD_ReferenceSystem>
                       <gmd:referenceSystemIdentifier>
                           <gmd:RS_Identifier>
                               <gmd:code>
                                   <gco:CharacterString><xsl:value-of select="spatial/indspref"></xsl:value-of></gco:CharacterString>
                               </gmd:code>
                           </gmd:RS_Identifier>
                       </gmd:referenceSystemIdentifier>
                   </gmd:MD_ReferenceSystem>
               </gmd:referenceSystemInfo>
           </xsl:if>
       
           <xsl:if test="spatial/sprefs">
               <xsl:for-each select="spatial/sprefs/spref">
                   <gmd:referenceSystemInfo>
                       <gmd:MD_ReferenceSystem>
                           <gmd:referenceSystemIdentifier>
                               <gmd:RS_Identifier>
                                   <gmd:authority>
                                       <gmd:CI_Citation>
                                           <gmd:title>
                                               <gco:CharacterString><xsl:value-of select="title"/></gco:CharacterString>
                                           </gmd:title>
                                           <gmd:date>
                                               <gmd:CI_Date>
                                                   <gmd:date gco:nilReason="unknown"/>
                                                   <gmd:dateType>
                                                       <gmd:CI_DateTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode"
                                                           codeListValue="revision">revision</gmd:CI_DateTypeCode>
                                                   </gmd:dateType>
                                               </gmd:CI_Date>
                                           </gmd:date>
                                           <gmd:citedResponsibleParty>
                                               <gmd:CI_ResponsibleParty>
                                                   <gmd:contactInfo>
                                                       <gmd:CI_Contact>
                                                           <gmd:onlineResource>
                                                               <gmd:CI_OnlineResource>
                                                                   <gmd:linkage>
                                                                       <gmd:URL><xsl:value-of select="onlineref"/></gmd:URL>
                                                                   </gmd:linkage>
                                                               </gmd:CI_OnlineResource>
                                                           </gmd:onlineResource>
                                                       </gmd:CI_Contact>
                                                   </gmd:contactInfo>
                                                   <gmd:role>
                                                       <gmd:CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                                                           codeListValue="resourceProvider">resourceProvider</gmd:CI_RoleCode>
                                                   </gmd:role>
                                               </gmd:CI_ResponsibleParty>
                                           </gmd:citedResponsibleParty>
                                       </gmd:CI_Citation>
                                   </gmd:authority>
                                   <gmd:code>
                                       <gco:CharacterString><xsl:value-of select="code"/></gco:CharacterString>
                                   </gmd:code>
                               </gmd:RS_Identifier>
                           </gmd:referenceSystemIdentifier>
                       </gmd:MD_ReferenceSystem>
                   </gmd:referenceSystemInfo>
               </xsl:for-each>
           </xsl:if>
       
           <gmd:identificationInfo>
               <gmd:MD_DataIdentification>
                   <xsl:variable name="id-citation-id" select="identification/citation[@role='identify']/@ref"></xsl:variable>
                   <xsl:variable name="id-citation" select="$all-citations/citation[@id=$id-citation-id]"></xsl:variable>
                   <gmd:citation>
                       <gmd:CI_Citation>
                           <gmd:title>
                               <gco:CharacterString><xsl:value-of select="identification/title"/></gco:CharacterString>
                           </gmd:title>
                           
                           
                           <gmd:date>
                               <gmd:CI_Date>
                                   <gmd:date>
                                       <xsl:variable name="pub-datetime">
                                           <xsl:call-template name="format-datetime">
                                               <xsl:with-param name="datestring" select="fn:normalize-space($id-citation/publication/pubdate/@date)"></xsl:with-param>
                                               <xsl:with-param name="timestring" select="fn:normalize-space($id-citation/publication/pubdate/@time)"></xsl:with-param>
                                           </xsl:call-template>
                                       </xsl:variable>
                                       <xsl:choose>
                                           <xsl:when test="fn:contains($pub-datetime, 'unknown') or fn:contains($pub-datetime, 'present')">
                                               <xsl:attribute name="gco:nilReason" select="'unknown'"/>
                                           </xsl:when>
                                           <xsl:when test="fn:contains($pub-datetime, 'T') and fn:contains($pub-datetime, ':')">
                                               <gco:DateTime>
                                                   <xsl:value-of select="$pub-datetime"/>
                                               </gco:DateTime>
                                           </xsl:when>
                                           <xsl:otherwise>
                                               <gco:Date>
                                                   <xsl:value-of select="$pub-datetime"/>
                                               </gco:Date>
                                           </xsl:otherwise>
                                       </xsl:choose>
                                   </gmd:date>                                   
                                   <gmd:dateType>
                                       <gmd:CI_DateTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode"
                                           codeListValue="publication">publication</gmd:CI_DateTypeCode>
                                   </gmd:dateType>
                               </gmd:CI_Date>
                           </gmd:date>
                           
                           
                           <gmd:identifier>
                               <gmd:MD_Identifier>
                                   <gmd:code>
                                       <gco:CharacterString>Downloadable Data</gco:CharacterString>
                                   </gmd:code>
                               </gmd:MD_Identifier>
                           </gmd:identifier>
                           <!-- the citation ref -->
                           <gmd:citedResponsibleParty>
                               <gmd:CI_ResponsibleParty>
                                   <gmd:organisationName>
                                       <gco:CharacterString><xsl:value-of select="$id-citation/origin"/></gco:CharacterString>
                                   </gmd:organisationName>
                                   <gmd:role>
                                       <gmd:CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                                           codeListValue="originator">originator</gmd:CI_RoleCode>
                                   </gmd:role>
                               </gmd:CI_ResponsibleParty>
                           </gmd:citedResponsibleParty>
                           <!-- the publication ref -->
                           <xsl:if test="$id-citation/publication/publisher or $id-citation/publication/place">
                               <gmd:citedResponsibleParty>
                                   <gmd:CI_ResponsibleParty>
                                       <gmd:organisationName>
                                           <xsl:if test="$id-citation/publication/publisher">
                                               <gco:CharacterString><xsl:value-of select="$id-citation/publication/publisher"/></gco:CharacterString>
                                           </xsl:if>
                                       </gmd:organisationName>
                                       <xsl:if test="$id-citation/publication/place">
                                           <gmd:contactInfo>
                                               <gmd:CI_Contact>
                                                   <gmd:address>
                                                       <gmd:CI_Address>
                                                           <gmd:city>
                                                               <gco:CharacterString>
                                                                   <xsl:choose>
                                                                       <xsl:when test="fn:contains($id-citation/publication/place, ';')">
                                                                           <xsl:value-of select="fn:substring-before($id-citation/publication/place, ';')"/>
                                                                       </xsl:when>
                                                                       <xsl:when test="fn:contains($id-citation/publication/place, ',')">
                                                                           <xsl:value-of select="fn:substring-before($id-citation/publication/place, ',')"/>
                                                                       </xsl:when>
                                                                   </xsl:choose>
                                                               </gco:CharacterString>
                                                           </gmd:city>
                                                           <gmd:administrativeArea>
                                                               <gco:CharacterString>
                                                                   <xsl:choose>
                                                                       <xsl:when test="fn:contains($id-citation/publication/place, ';')">
                                                                           <xsl:value-of select="fn:substring-after($id-citation/publication/place, ';')"/>
                                                                       </xsl:when>
                                                                       <xsl:when test="fn:contains($id-citation/publication/place, ',')">
                                                                           <xsl:value-of select="fn:substring-after($id-citation/publication/place, ',')"/>
                                                                       </xsl:when>
                                                                   </xsl:choose>
                                                               </gco:CharacterString>
                                                           </gmd:administrativeArea>
                                                       </gmd:CI_Address>
                                                   </gmd:address>
                                               </gmd:CI_Contact>
                                           </gmd:contactInfo>
                                       </xsl:if>
                                       <gmd:role>
                                           <gmd:CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                                               codeListValue="publisher">publisher</gmd:CI_RoleCode>
                                       </gmd:role>
                                   </gmd:CI_ResponsibleParty>
                               </gmd:citedResponsibleParty>
                           </xsl:if>
                       </gmd:CI_Citation>
                   </gmd:citation>

                   <gmd:abstract>
                       <gco:CharacterString><xsl:value-of select="identification/abstract"></xsl:value-of></gco:CharacterString>
                   </gmd:abstract>
                   <gmd:purpose>
                       <gco:CharacterString><xsl:value-of select="identification/purpose"></xsl:value-of></gco:CharacterString>
                   </gmd:purpose>
                   <xsl:if test="identification/credit">
                       <gmd:credit>
                           <gco:CharacterString><xsl:value-of select="identification/credit"></xsl:value-of></gco:CharacterString>
                       </gmd:credit>
                   </xsl:if>
                   <xsl:if test="quality/progress">
                       <xsl:variable name="status-value">
                           <xsl:value-of select="fn:lower-case(quality/progress)"></xsl:value-of>
                       </xsl:variable>
                       <gmd:status>
                           <gmd:MD_ProgressCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_ProgressCode"
                               codeListValue="{$status-value}"></gmd:MD_ProgressCode>
                       </gmd:status>
                   </xsl:if>
<!--               TODO: which contact is this again? also double-check the first contact, maybe it's the metadata contact instead?    -->
                   <gmd:pointOfContact>
                       <gmd:CI_ResponsibleParty>
                           <xsl:apply-templates select="$all-contacts/contact[@id=$identity-ptcontac-id]"></xsl:apply-templates>
                           <gmd:role>
                               <xsl:variable name="rolecode">
                                   <xsl:choose>
                                       <xsl:when test="identification/contact[@role='point-contact']">
                                           <xsl:value-of select="'pointOfContact'"></xsl:value-of>
                                       </xsl:when>
                                   </xsl:choose>
                               </xsl:variable>
                               <gmd:CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                                   codeListValue="{$rolecode}"></gmd:CI_RoleCode>
                           </gmd:role>
                       </gmd:CI_ResponsibleParty>
                   </gmd:pointOfContact>
                   
                   <gmd:resourceMaintenance>
                       <gmd:MD_MaintenanceInformation>
                           <gmd:maintenanceAndUpdateFrequency>
                               <xsl:variable name="update-value">
                                   <xsl:choose>
                                       <xsl:when test="fn:lower-case(quality/update)='none planned' or fn:lower-case(quality/update)='not planned'">
                                           <xsl:value-of select="'notPlanned'"/>
                                       </xsl:when>
                                       <xsl:when test="fn:lower-case(quality/update)='as needed'">
                                           <xsl:value-of select="'asNeeded'"/>
                                       </xsl:when>
                                       <xsl:otherwise>
                                           <xsl:value-of select="'unknown'"/>
                                       </xsl:otherwise>
                                   </xsl:choose>
                               </xsl:variable>
                               <gmd:MD_MaintenanceFrequencyCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_MaintenanceFrequencyCode"
                                   codeListValue="{$update-value}"></gmd:MD_MaintenanceFrequencyCode>
                           </gmd:maintenanceAndUpdateFrequency>
                       </gmd:MD_MaintenanceInformation>
                   </gmd:resourceMaintenance>
                   
                   <xsl:if test="identification/browse">
                       <gmd:graphicOverview>
                           <gmd:MD_BrowseGraphic>
                               <gmd:fileName>
                                   <gco:CharacterString><xsl:value-of select="identification/browse/filename"></xsl:value-of></gco:CharacterString>
                               </gmd:fileName>
                               <gmd:fileDescription>
                                   <gco:CharacterString><xsl:value-of select="identification/browse/description"></xsl:value-of></gco:CharacterString>
                               </gmd:fileDescription>
                               <gmd:fileType>
                                   <gco:CharacterString><xsl:value-of select="identification/browse/filetype"></xsl:value-of></gco:CharacterString>
                               </gmd:fileType>
                           </gmd:MD_BrowseGraphic>
                       </gmd:graphicOverview>
                   </xsl:if>
               
                   <xsl:for-each select="identification/themes/theme">
                       <gmd:descriptiveKeywords>
                           <gmd:MD_Keywords>
                               <xsl:for-each select="term">
                                   <gmd:keyword>
                                       <gco:CharacterString><xsl:value-of select="."></xsl:value-of></gco:CharacterString>
                                   </gmd:keyword>
                               </xsl:for-each>
                               <gmd:type>
                                   <gmd:MD_KeywordTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode"
                                       codeListValue="theme"></gmd:MD_KeywordTypeCode>
                               </gmd:type>
                               <gmd:thesaurusName>
                                   <gmd:CI_Citation>
                                       <gmd:title>
                                           <gco:CharacterString><xsl:value-of select="@thesaurus"></xsl:value-of></gco:CharacterString>
                                       </gmd:title>
                                       <gmd:date gco:nilReason="unknown"></gmd:date>
                                   </gmd:CI_Citation>
                               </gmd:thesaurusName>
                           </gmd:MD_Keywords>
                       </gmd:descriptiveKeywords>
                   </xsl:for-each>
                   <xsl:for-each select="identification/places/place">
                       <gmd:descriptiveKeywords>
                           <gmd:MD_Keywords>
                               <xsl:for-each select="term">
                                   <gmd:keyword>
                                       <gco:CharacterString><xsl:value-of select="."></xsl:value-of></gco:CharacterString>
                                   </gmd:keyword>
                               </xsl:for-each>
                               <gmd:type>
                                   <gmd:MD_KeywordTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode"
                                       codeListValue="place"></gmd:MD_KeywordTypeCode>
                               </gmd:type>
                               <gmd:thesaurusName>
                                   <gmd:CI_Citation>
                                       <gmd:title>
                                           <gco:CharacterString><xsl:value-of select="@thesaurus"></xsl:value-of></gco:CharacterString>
                                       </gmd:title>
                                       <gmd:date gco:nilReason="unknown"></gmd:date>
                                   </gmd:CI_Citation>
                               </gmd:thesaurusName>
                           </gmd:MD_Keywords>
                       </gmd:descriptiveKeywords>
                   </xsl:for-each>
               
                   <xsl:if test="constraints/access[@type='data'] or constraints/use[@type='data']">
                      <gmd:resourceConstraints>
                          <gmd:MD_LegalConstraints>
                              <xsl:variable name="access-constraints">
                                  <xsl:choose>
                                      <xsl:when test="constraints/access">
                                          <xsl:value-of select="concat('Access Constraints: ', constraints/access[@type='data'])"></xsl:value-of>
                                      </xsl:when>
                                  </xsl:choose>
                              </xsl:variable>
                              <xsl:variable name="use-constraints">
                                  <xsl:choose>
                                      <xsl:when test="constraints/use[@type='data']">
                                          <xsl:value-of select="concat('Use Constraints: ', constraints/use[@type='data'])"></xsl:value-of>
                                      </xsl:when>
                                  </xsl:choose>
                              </xsl:variable>
                              <xsl:if test="$access-constraints">
                                  <gmd:accessConstraints>
                                      <gmd:MD_RestrictionCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_RestrictionCode"
                                          codeListValue="otherRestrictions"></gmd:MD_RestrictionCode>
                                  </gmd:accessConstraints>
                              </xsl:if>
                              <xsl:if test="$use-constraints">
                                <gmd:useConstraints>
                                    <gmd:MD_RestrictionCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_RestrictionCode"
                                         codeListValue="otherRestrictions"></gmd:MD_RestrictionCode>
                                </gmd:useConstraints>
                              </xsl:if>
                              <gmd:otherConstraints>
                                  <gco:CharacterString><xsl:value-of select="$access-constraints[text() != ''] | $use-constraints[text() != '']" separator=". "></xsl:value-of></gco:CharacterString>
                              </gmd:otherConstraints>
                          </gmd:MD_LegalConstraints>
                      </gmd:resourceConstraints>
                   </xsl:if>
                   
                   <xsl:if test="identification/citation/citation[@role='crossref' or @role='larger-work']">
                       <xsl:for-each select="identification/citation/citation[@role='crossref' or @role='larger-work']">
                           <xsl:variable name="aggregate-citation-id" select="@ref"/>
                           <xsl:variable name="aggregate-role" select="@role"/>
                           <xsl:variable name="aggregate-citation">
                               <xsl:copy-of select="$all-citations/citation[@id=$aggregate-citation-id]"></xsl:copy-of>
                           </xsl:variable>
                           
                           <gmd:aggregationInfo>
                               <gmd:MD_AggregateInformation>
                                   <gmd:aggregateDataSetName>
                                       <gmd:CI_Citation>
                                           <gmd:title>
                                               <gco:CharacterString><xsl:value-of select="$aggregate-citation/citation/title"></xsl:value-of></gco:CharacterString>
                                           </gmd:title>
                                           <gmd:date>
                                               <gmd:CI_Date>
                                                   <gmd:date>
                                                       <xsl:choose>
                                                           <xsl:when test="$aggregate-citation/citation/publication/pubdate[@date='Unknown']">
                                                               <xsl:attribute name="gco:nilReason">unknown</xsl:attribute>
                                                           </xsl:when>
                                                           <xsl:otherwise>
<!--                                                           TODO: convert to a proper iso datetime    -->
                                                               <gco:Date><xsl:value-of select="$aggregate-citation/citation/publication/pubdate/@date"></xsl:value-of></gco:Date>
                                                           </xsl:otherwise>
                                                       </xsl:choose>
                                                   </gmd:date>
                                                   <gmd:dateType>
                                                       <gmd:CI_DateTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode"
                                                           codeListValue="publication"></gmd:CI_DateTypeCode>
                                                   </gmd:dateType>
                                               </gmd:CI_Date>
                                           </gmd:date>
                                           <xsl:if test="$aggregate-citation/citation/edition">
                                               <gmd:edition>
                                                   <gco:CharacterString><xsl:value-of select="$aggregate-citation/citation/edition"></xsl:value-of></gco:CharacterString>
                                               </gmd:edition>
                                           </xsl:if>
                                           
                                           <gmd:citedResponsibleParty>
                                               <gmd:CI_ResponsibleParty>
                                                   <gmd:organisationName>
                                                       <gco:CharacterString><xsl:value-of select="$aggregate-citation/citation/origin"></xsl:value-of></gco:CharacterString>
                                                   </gmd:organisationName>
                                                   <xsl:if test="$aggregate-citation/citation/onlink">
                                                       <gmd:contactInfo>
                                                           <gmd:CI_Contact>
                                                               <gmd:onlineResource>
                                                                   <gmd:CI_OnlineResource>
                                                                       <gmd:linkage>
                                                                           <gmd:URL><xsl:value-of select="$aggregate-citation/citation/onlink[1]"></xsl:value-of></gmd:URL>
                                                                       </gmd:linkage>
                                                                   </gmd:CI_OnlineResource>
                                                               </gmd:onlineResource>
                                                           </gmd:CI_Contact>
                                                       </gmd:contactInfo>
                                                   </xsl:if>
                                                   <gmd:role>
                                                       <gmd:CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                                                           codeListValue="originator"></gmd:CI_RoleCode>
                                                   </gmd:role>
                                               </gmd:CI_ResponsibleParty>
                                           </gmd:citedResponsibleParty>
                                           <xsl:if test="$aggregate-citation/othercit">
                                               <gmd:otherCitationDetails>
                                                   <gco:CharacterString><xsl:value-of select="$aggregate-citation/citation/othercit"></xsl:value-of></gco:CharacterString>
                                               </gmd:otherCitationDetails>
                                           </xsl:if>
                                       </gmd:CI_Citation>
                                   </gmd:aggregateDataSetName>
                                   <gmd:associationType>
                                       <xsl:variable name="association-type">
                                           <xsl:choose>
                                               <xsl:when test="$aggregate-role='larger-work'">
                                                   <xsl:value-of select="'largerWorkCitation'"/>
                                               </xsl:when>
                                               <xsl:when test="$aggregate-role='crossref'">
                                                   <xsl:value-of select="'crossReference'"/>
                                               </xsl:when>
                                               <xsl:otherwise>
                                                   <xsl:value-of select="'unknown'"/>
                                               </xsl:otherwise>
                                           </xsl:choose>
                                       </xsl:variable>
                                       <gmd:DS_AssociationTypeCode>
                                           <xsl:attribute name="codeList">
                                               <xsl:sequence select="'http://www.ngdc.noaa.gov/metadata/published/xsd/schema/resources/Codelist/gmxCodelists.xml#DS_AssociationTypeCode'"/>
                                           </xsl:attribute>
                                           <xsl:attribute name="codeListValue">
                                               <xsl:sequence select="$association-type"/>
                                           </xsl:attribute>
                                       </gmd:DS_AssociationTypeCode>
                                   </gmd:associationType>
                               </gmd:MD_AggregateInformation>
                           </gmd:aggregationInfo>
                           
   
                          
                       </xsl:for-each>
                   </xsl:if>
                   
                    <xsl:if test="spatial">
                        <xsl:variable name="spref-type">
                            <xsl:choose>
                                <xsl:when test="spatial/raster">
                                    <xsl:value-of select="'grid'"></xsl:value-of>
                                </xsl:when>
                                <xsl:when test="spatial/vector">
                                    <xsl:value-of select="'vector'"></xsl:value-of>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        <gmd:spatialRepresentationType>
                            <gmd:MD_SpatialRepresentationTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_SpatialRepresentationTypeCode"
                                codeListValue="{$spref-type}"></gmd:MD_SpatialRepresentationTypeCode>
                        </gmd:spatialRepresentationType>
                    </xsl:if>
<!--               TODO: aggregation info    -->
                   
                   <gmd:language>
                       <gco:CharacterString>eng; USA</gco:CharacterString>
                   </gmd:language>
                   
                   <xsl:if test="identification/isotopic">
                       <gmd:topicCategory>
                           <gmd:MD_TopicCategoryCode><xsl:value-of select="identification/isotopic"></xsl:value-of></gmd:MD_TopicCategoryCode>
                       </gmd:topicCategory>
                   </xsl:if>

                   <xsl:if test="identification/native">
                       <gmd:environmentDescription>
                           <gco:CharacterString><xsl:value-of select="identification/native"></xsl:value-of></gco:CharacterString>
                       </gmd:environmentDescription>
                   </xsl:if>
               
                   <gmd:extent>
                       <gmd:EX_Extent id="boundingExtent">
                           <xsl:if test="spatial">
                               <gmd:geographicElement>
                                   <gmd:EX_GeographicBoundingBox id="geographicExtent">
                                       <gmd:westBoundLongitude>
                                           <gco:Decimal><xsl:value-of select="spatial/west"></xsl:value-of></gco:Decimal>
                                       </gmd:westBoundLongitude>
                                       <gmd:eastBoundLongitude>
                                           <gco:Decimal><xsl:value-of select="spatial/east"></xsl:value-of></gco:Decimal>
                                       </gmd:eastBoundLongitude>
                                       <gmd:southBoundLatitude>
                                           <gco:Decimal><xsl:value-of select="spatial/south"></xsl:value-of></gco:Decimal>
                                       </gmd:southBoundLatitude>
                                       <gmd:northBoundLatitude>
                                           <gco:Decimal><xsl:value-of select="spatial/north"></xsl:value-of></gco:Decimal>
                                       </gmd:northBoundLatitude>
                                   </gmd:EX_GeographicBoundingBox>
                               </gmd:geographicElement>
                           </xsl:if>
                           <xsl:choose>
                               <xsl:when test="identification/time/range">
                                   <gmd:temporalElement>
                                       <gmd:EX_TemporalExtent>
                                           <gmd:extent>
                                               <gml:TimePeriod gml:id="timePeriodExtent">
                                                   <gml:description><xsl:value-of select="identification/time/current"></xsl:value-of></gml:description>
                                              
                                                       <xsl:call-template name="generate-timeExtent">
                                                           <xsl:with-param name="datestring" select="identification/time/range/start/@date"></xsl:with-param>
                                                           <xsl:with-param name="timestring" select="identification/time/range/start/@time"></xsl:with-param>
                                                           <xsl:with-param name="tag-type" select="'begin'"></xsl:with-param>
                                                       </xsl:call-template>
                                                   
                                                   
                                                   <xsl:call-template name="generate-timeExtent">
                                                       <xsl:with-param name="datestring" select="identification/time/range/end/@date"></xsl:with-param>
                                                       <xsl:with-param name="timestring" select="identification/time/range/end/@time"></xsl:with-param>
                                                       <xsl:with-param name="tag-type" select="'end'"></xsl:with-param>
                                                   </xsl:call-template>
                                               
                                               </gml:TimePeriod>
                                           </gmd:extent>
                                       </gmd:EX_TemporalExtent>
                                   </gmd:temporalElement>
                               </xsl:when>
                               <xsl:when test="count(identification/time/single) > 1">
                                   <xsl:for-each select="identification/time/single">
<!--                                   TODO: make sure we're using the right format for these    -->
                                       <gmd:temporalElement>
                                           <gmd:EX_TemporalExtent>
                                               <gmd:extent>
                                                   <gml:TimeInstant gml:id="{generate-id(.)}">
                                                       <gml:description><xsl:value-of select="../../current"></xsl:value-of></gml:description>
                                                       <xsl:call-template name="generate-timeExtent">
                                                           <xsl:with-param name="datestring" select="@date"></xsl:with-param>
                                                           <xsl:with-param name="timestring" select="@time"></xsl:with-param>
                                                           <xsl:with-param name="tag-type" select="'single'"></xsl:with-param>
                                                       </xsl:call-template>
                                                   </gml:TimeInstant>
                                               </gmd:extent>
                                           </gmd:EX_TemporalExtent>
                                       </gmd:temporalElement>
                                   </xsl:for-each>
                               </xsl:when>
                               <xsl:when test="count(identification/time/single) = 1">
                                   <gmd:temporalElement>
                                       <gmd:EX_TemporalExtent>
                                           <gmd:extent>
                                               <gml:TimeInstant gml:id="{generate-id(identification/time/single)}">
                                                   <gml:description><xsl:value-of select="identification/time/current"></xsl:value-of></gml:description>
                                                   <xsl:call-template name="generate-timeExtent">
                                                       <xsl:with-param name="datestring" select="identification/time/single/@date"></xsl:with-param>
                                                       <xsl:with-param name="timestring" select="identification/time/single/@time"></xsl:with-param>
                                                       <xsl:with-param name="tag-type" select="'single'"></xsl:with-param>
                                                   </xsl:call-template>
                                               </gml:TimeInstant>
                                           </gmd:extent>
                                       </gmd:EX_TemporalExtent>
                                   </gmd:temporalElement>
                               </xsl:when>
                           </xsl:choose>
                       </gmd:EX_Extent>
                   </gmd:extent>
               
                   <xsl:if test="identification/supplinfo">
                       <gmd:supplementalInformation>
                           <gco:CharacterString><xsl:value-of select="identification/supplinfo"></xsl:value-of></gco:CharacterString>
                       </gmd:supplementalInformation>
                   </xsl:if>
               
               </gmd:MD_DataIdentification>
           </gmd:identificationInfo>
           <xsl:if test="attributes and (spatial/vector or not(spatial))">
               <gmd:contentInfo>
                    <gmd:MD_FeatureCatalogueDescription>
                        <gmd:includedWithDataset>
                            <gco:Boolean>true</gco:Boolean>
                        </gmd:includedWithDataset>
                        <gmd:featureTypes>
                            <gco:LocalName codeSpace="{attributes/entity/label}"></gco:LocalName>
                        </gmd:featureTypes>
                        <gmd:featureCatalogueCitation>
                            <gmd:CI_Citation>
                                <gmd:title>
                                    <gco:CharacterString>Entity and Attribute Information</gco:CharacterString>
                                </gmd:title>
                                <gmd:date gco:nilReason="unknown"></gmd:date>                            
                                <gmd:citedResponsibleParty>
                                    <gmd:CI_ResponsibleParty>
                                        <gmd:contactInfo>
                                            <gmd:CI_Contact>
                                                <gmd:onlineResource>
                                                    <gmd:CI_OnlineResource>
                                                        <gmd:linkage>
                                                            <gmd:URL>
                                                                <xsl:value-of select="$fc-url"/>
                                                            </gmd:URL>
                                                        </gmd:linkage>
                                                        <gmd:protocol>
                                                            <gco:CharacterString>
                                                                http
                                                            </gco:CharacterString>
                                                        </gmd:protocol>
                                                    </gmd:CI_OnlineResource>
                                                </gmd:onlineResource>
                                            </gmd:CI_Contact>
                                        </gmd:contactInfo>
                                        <gmd:role/>
                                    </gmd:CI_ResponsibleParty>
                                </gmd:citedResponsibleParty>
                                
                                <xsl:variable name="eaoverview">
                                    <xsl:choose>
                                        <xsl:when test="attributes/overview">
                                            <xsl:value-of select="attributes/overview"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:variable name="eacite">
                                    <xsl:choose>
                                        <xsl:when test="attributes/eacite">
                                            <xsl:value-of select="attributes/eacite"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:variable>
                                
                                <xsl:if test="$eaoverview or $eacite">
                                    <gmd:otherCitationDetails>
                                        <gco:CharacterString><xsl:value-of select="$eaoverview[text() != ''] | $eacite[text() != '']" separator=" "/></gco:CharacterString>
                                    </gmd:otherCitationDetails>
                                </xsl:if>

                            </gmd:CI_Citation>
                        </gmd:featureCatalogueCitation>
                    </gmd:MD_FeatureCatalogueDescription>
               </gmd:contentInfo>
           </xsl:if>
           <xsl:if test="spatial/raster and attributes/attr and fn:count(attributes/attr) = 1">
               <!-- TODO: update for vat definition (not sure how to tell without a person, but whatever) -->
               <gmd:contentInfo>
                   <gmd:MD_CoverageDescription>
                       <gmd:attributeDescription>
                           <gco:RecordType/>
                       </gmd:attributeDescription>
                       <gmd:contentType>
                           <gmd:MD_CoverageContentTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_CoverageContentTypeCode"
                               codeListValue="physicalMeasurement"></gmd:MD_CoverageContentTypeCode>
                       </gmd:contentType>
                       <gmd:dimension>
                           <gmd:MD_Band>
                               <gmd:descriptor>
                                   <gco:CharacterString><xsl:value-of select="fn:concat(attributes/attr/label, '(', attributes/attr/definition, ')')"/></gco:CharacterString>
                               </gmd:descriptor>
                               <gmd:units>
                                   <gml:UnitDefinition gml:id="{generate-id()}">
                                       <gml:identifier codeSpace=""/>
                                       <xsl:variable name="units" select="attributes/attr/range/units[1]"/>
                                       <gml:name><xsl:value-of select="if ($units) then $units else 'Unknown'"/></gml:name>
                                   </gml:UnitDefinition>
                               </gmd:units>
                           </gmd:MD_Band>
                       </gmd:dimension>
                   </gmd:MD_CoverageDescription>
               </gmd:contentInfo>
           </xsl:if>
           <xsl:if test="spatial/raster and quality/cloud">
               <gmd:contentInfo>
                   <gmd:MD_ImageDescription>
                       <gmd:attributeDescription>
                           <gco:RecordType/>
                       </gmd:attributeDescription>
                       <gmd:contentType>
                           <gmd:MD_CoverageContentTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_CoverageContentTypeCode"
                               codeListValue="image"></gmd:MD_CoverageContentTypeCode>
                       </gmd:contentType>
                       <xsl:choose>
                           <xsl:when test="quality/cloud">
                               <gmd:cloudCoverPercentage>
                                   <gco:Real><xsl:value-of select="quality/cloud"/></gco:Real>
                               </gmd:cloudCoverPercentage>
                           </xsl:when>
                           <xsl:otherwise>
                               <gmd:cloudCoverPercentage gco:nilReason="unknown"/>
                           </xsl:otherwise>
                       </xsl:choose>
                       
                   </gmd:MD_ImageDescription>
               </gmd:contentInfo>
           </xsl:if>
           
           <xsl:if test="distribution">
               <gmd:distributionInfo>
                   <gmd:MD_Distribution>
                       <xsl:for-each select="distribution/distributor">
                           <xsl:variable name="dist-contact-id" select="contact/@ref"/>
                           <xsl:variable name="dist-contact" select="$all-contacts/contact[@id=$dist-contact-id]"></xsl:variable>
                           <xsl:variable name="fees" select="fees"></xsl:variable>
                           <xsl:variable name="ordering" select="ordering"></xsl:variable>

                           <xsl:for-each select="downloads/download">
                               <gmd:distributor>
                                   <gmd:MD_Distributor>
                                       <gmd:distributorContact>
                                           <gmd:CI_ResponsibleParty>
                                               <xsl:if test="$dist-contact/organization">
                                                   <gmd:organisationName>
                                                       <gco:CharacterString>
                                                           <xsl:value-of select="$dist-contact/organization/name"/>
                                                       </gco:CharacterString>
                                                   </gmd:organisationName>
                                               </xsl:if>
                                               <xsl:if test="$dist-contact/position">
                                                   <gmd:positionName>
                                                       <gco:CharacterString>
                                                           <xsl:value-of select="$dist-contact/position"/>
                                                       </gco:CharacterString>
                                                   </gmd:positionName>
                                               </xsl:if>
                                               <gmd:contactInfo>
                                                   <gmd:CI_Contact>
                                                       <xsl:if test="$dist-contact/voice or $dist-contact/fax">
                                                           <gmd:phone>
                                                               <gmd:CI_Telephone>
                                                                   <xsl:if test="$dist-contact/voice">
                                                                       <gmd:voice>
                                                                           <gco:CharacterString><xsl:value-of select="$dist-contact/voice"/></gco:CharacterString>
                                                                       </gmd:voice>
                                                                   </xsl:if>
                                                                   <xsl:if test="$dist-contact/fax">
                                                                       <gmd:facsimile>
                                                                           <gco:CharacterString><xsl:value-of select="$dist-contact/fax"/></gco:CharacterString>
                                                                       </gmd:facsimile>
                                                                   </xsl:if>
                                                               </gmd:CI_Telephone>
                                                           </gmd:phone>
                                                       </xsl:if>
                                                       
                                                       <!-- TODO: add support for multiple addresses! -->
                                                       <gmd:address>
                                                           <gmd:CI_Address>
                                                               <xsl:for-each select="$dist-contact/address/addr">
                                                                   <gmd:deliveryPoint>
                                                                       <gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
                                                                   </gmd:deliveryPoint>
                                                               </xsl:for-each>
                                                               <gmd:city>
                                                                   <gco:CharacterString><xsl:value-of select="$dist-contact/address/city"/></gco:CharacterString>
                                                               </gmd:city>
                                                               <gmd:administrativeArea>
                                                                   <gco:CharacterString><xsl:value-of select="$dist-contact/address/state"/></gco:CharacterString>
                                                               </gmd:administrativeArea>
                                                               <gmd:postalCode>
                                                                   <gco:CharacterString><xsl:value-of select="$dist-contact/address/postal"/></gco:CharacterString>
                                                               </gmd:postalCode>
                                                               <gmd:country>
                                                                   <gco:CharacterString><xsl:value-of select="$dist-contact/address/country"/></gco:CharacterString>
                                                               </gmd:country>
                                                               <xsl:if test="$dist-contact/email">
                                                                   <gmd:electronicMailAddress>
                                                                       <gco:CharacterString><xsl:value-of select="$dist-contact/email"/></gco:CharacterString>
                                                                   </gmd:electronicMailAddress>
                                                               </xsl:if>
                                                           </gmd:CI_Address>
                                                       </gmd:address>
                                                       <xsl:if test="$dist-contact/hours">
                                                           <gmd:hoursOfService>
                                                               <gco:CharacterString><xsl:value-of select="$dist-contact/hours"/></gco:CharacterString>
                                                           </gmd:hoursOfService>
                                                       </xsl:if>
                                                       <xsl:if test="$dist-contact/instructions">
                                                           <gmd:contactInstructions>
                                                               <gco:CharacterString><xsl:value-of select="$dist-contact/instructions"/></gco:CharacterString>
                                                           </gmd:contactInstructions>
                                                       </xsl:if>
                                                   </gmd:CI_Contact>
                                               </gmd:contactInfo>
                                               <gmd:role>
                                                   <gmd:CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                                                       codeListValue="distributor">distributor</gmd:CI_RoleCode>
                                               </gmd:role>
                                           </gmd:CI_ResponsibleParty>
                                       </gmd:distributorContact>
                                       <gmd:distributionOrderProcess>
                                           <gmd:MD_StandardOrderProcess>
                                               <gmd:fees>
                                                   <gco:CharacterString><xsl:value-of select="$fees"/></gco:CharacterString>
                                               </gmd:fees>
                                               <gmd:orderingInstructions>
                                                   <gco:CharacterString><xsl:value-of select="$ordering"/></gco:CharacterString>
                                               </gmd:orderingInstructions>
                                           </gmd:MD_StandardOrderProcess>
                                       </gmd:distributionOrderProcess>
                                       <gmd:distributorFormat>
                                           <gmd:MD_Format>
                                               <gmd:name>
                                                   <gco:CharacterString><xsl:value-of select="type"/></gco:CharacterString>
                                               </gmd:name>
                                               <gmd:version gco:nilReason="unknown"/>
                                           </gmd:MD_Format>
                                       </gmd:distributorFormat>
                                       <gmd:distributorTransferOptions>
                                           <gmd:MD_DigitalTransferOptions>
                                               <xsl:if test="size">
                                                   <gmd:transferSize>
                                                       <gco:Real><xsl:value-of select="size"/></gco:Real>
                                                   </gmd:transferSize>
                                               </xsl:if>
                                               <gmd:onLine>
                                                   <gmd:CI_OnlineResource>
                                                       <gmd:linkage>
                                                           <gmd:URL><xsl:value-of select="link"/></gmd:URL>
                                                       </gmd:linkage>
                                                   </gmd:CI_OnlineResource>
                                               </gmd:onLine>
                                           </gmd:MD_DigitalTransferOptions>
                                       </gmd:distributorTransferOptions>
                                   </gmd:MD_Distributor>
                               </gmd:distributor>
                           </xsl:for-each>
                       </xsl:for-each>
                       
                       <!-- check for onlinks in the main citation -->
                       <xsl:variable name="id-citation-id" select="identification/citation[@role='identify']/@ref"></xsl:variable>
                       <xsl:variable name="id-citation" select="$all-citations/citation[@id=$id-citation-id]"></xsl:variable>
                       
                       <xsl:variable name="onlinks" select="$id-citation/onlink"/>
                       <xsl:if test="$onlinks">
                           <gmd:transferOptions>
                               <gmd:MD_DigitalTransferOptions>
                                    <xsl:for-each select="$onlinks">
                                        <gmd:onLine>
                                            <gmd:CI_OnlineResource>
                                                <gmd:linkage>
                                                    <gmd:URL><xsl:value-of select="."/></gmd:URL>
                                                </gmd:linkage>
                                            </gmd:CI_OnlineResource>
                                        </gmd:onLine>
                                    </xsl:for-each>
                               </gmd:MD_DigitalTransferOptions>
                           </gmd:transferOptions>
                       </xsl:if>
                   </gmd:MD_Distribution>
               </gmd:distributionInfo>
           </xsl:if>
           
           <gmd:dataQualityInfo>
               <gmd:DQ_DataQuality>
                    <gmd:scope gco:nilReason="unknown"></gmd:scope>
                    <xsl:if test="quality/qual[@type='horizontal']">
                        <xsl:for-each select="quality/qual[@type='horizontal']/quantitative">
                            <gmd:report>
                                <gmd:DQ_AbsoluteExternalPositionalAccuracy>
                                    <gmd:nameOfMeasure>
                                        <gco:CharacterString>Horizontal Positional Accuracy</gco:CharacterString>
                                    </gmd:nameOfMeasure>
                                    <gmd:measureDescription>
                                        <gco:CharacterString><xsl:value-of select="explanation"></xsl:value-of></gco:CharacterString>
                                    </gmd:measureDescription>
                                    <gmd:evaluationMethodDescription>
                                        <gco:CharacterString><xsl:value-of select="../report"></xsl:value-of></gco:CharacterString>
                                    </gmd:evaluationMethodDescription>
                                    <gmd:result>
                                        <gmd:DQ_QuantitativeResult>
                                            <gmd:valueUnit>
                                                <gml:BaseUnit gml:id="{generate-id()}">
                                                    <gml:identifier codeSpace="meters"></gml:identifier>
                                                    <gml:unitsSystem xlink:href="http://www.bipm.org/en/si/"></gml:unitsSystem>
                                                </gml:BaseUnit>
                                            </gmd:valueUnit>
                                            <gmd:value>
                                                <gco:Record><xsl:value-of select="value"></xsl:value-of></gco:Record>
                                            </gmd:value>
                                        </gmd:DQ_QuantitativeResult>
                                    </gmd:result>
                                </gmd:DQ_AbsoluteExternalPositionalAccuracy>
                            </gmd:report>
                        </xsl:for-each>
                    </xsl:if>
                    <xsl:if test="quality/qual[@type='vertical']">
                        
                        <xsl:for-each select="quality/qual[@type='vertical']/quantitative">
                            <gmd:report>
                                <gmd:DQ_AbsoluteExternalPositionalAccuracy>
                                    <gmd:nameOfMeasure>
                                        <gco:CharacterString>Vertical Positional Accuracy</gco:CharacterString>
                                    </gmd:nameOfMeasure>
                                    <gmd:measureDescription>
                                        <gco:CharacterString><xsl:value-of select="explanation"></xsl:value-of></gco:CharacterString>
                                    </gmd:measureDescription>
                                    <gmd:evaluationMethodDescription>
                                        <gco:CharacterString><xsl:value-of select="../report"></xsl:value-of></gco:CharacterString>
                                    </gmd:evaluationMethodDescription>
                                    <gmd:result>
                                        <gmd:DQ_QuantitativeResult>
                                            <gmd:valueUnit>
                                                <gml:BaseUnit gml:id="{generate-id()}">
                                                    <gml:identifier codeSpace="meters"></gml:identifier>
                                                    <gml:unitsSystem xlink:href="http://www.bipm.org/en/si/"></gml:unitsSystem>
                                                </gml:BaseUnit>
                                            </gmd:valueUnit>
                                            <gmd:value>
                                                <gco:Record><xsl:value-of select="value"></xsl:value-of></gco:Record>
                                            </gmd:value>
                                        </gmd:DQ_QuantitativeResult>
                                    </gmd:result>
                                </gmd:DQ_AbsoluteExternalPositionalAccuracy>
                            </gmd:report>
                        </xsl:for-each>
                    </xsl:if>
                    <gmd:report>
                        <gmd:DQ_CompletenessCommission>
                            <gmd:result gco:nilReason="unknown"></gmd:result>
                        </gmd:DQ_CompletenessCommission>
                    </gmd:report>
                    <xsl:if test="quality/complete">
                        <gmd:report>
                            <gmd:DQ_CompletenessOmission>
                                <gmd:evaluationMethodDescription>
                                    <gco:CharacterString><xsl:value-of select="quality/complete"></xsl:value-of></gco:CharacterString>
                                </gmd:evaluationMethodDescription>
                                <gmd:result gco:nilReason="unknown"></gmd:result>
                            </gmd:DQ_CompletenessOmission>
                        </gmd:report>
                    </xsl:if>
                    <xsl:if test="quality/logical">
                        <gmd:report>
                            <gmd:DQ_ConceptualConsistency>
                                <gmd:measureDescription>
                                    <gco:CharacterString><xsl:value-of select="quality/logical"></xsl:value-of></gco:CharacterString>
                                </gmd:measureDescription>
                                <gmd:result gco:nilReason="unknown"></gmd:result>
                            </gmd:DQ_ConceptualConsistency>
                        </gmd:report>
                    </xsl:if>
                    <xsl:if test="quality/qual[@type='attribute']">
                        <xsl:for-each select="quality/qual[@type='attribute']/quantitative">
                            <gmd:report>
                                <gmd:DQ_QuantitativeAttributeAccuracy>
                                    <gmd:nameOfMeasure>
                                        <gco:CharacterString>Quantitative Attribute Accuracy Assessment</gco:CharacterString>
                                    </gmd:nameOfMeasure>
                                    <gmd:measureDescription>
                                        <gco:CharacterString><xsl:value-of select="explanation"></xsl:value-of></gco:CharacterString>
                                    </gmd:measureDescription>
                                    <gmd:evaluationMethodDescription>
                                        <gco:CharacterString><xsl:value-of select="../report"></xsl:value-of></gco:CharacterString>
                                    </gmd:evaluationMethodDescription>
                                    <gmd:result>
                                        <gmd:DQ_QuantitativeResult>
                                            <gmd:valueUnit>
                                                <gml:BaseUnit gml:id="{generate-id()}">
                                                    <gml:identifier codeSpace="meters"></gml:identifier>
                                                    <gml:unitsSystem xlink:href="http://www.bipm.org/en/si/"></gml:unitsSystem>
                                                </gml:BaseUnit>
                                            </gmd:valueUnit>
                                            <gmd:value>
                                                <gco:Record><xsl:value-of select="value"></xsl:value-of></gco:Record>
                                            </gmd:value>
                                        </gmd:DQ_QuantitativeResult>
                                    </gmd:result>
                                </gmd:DQ_QuantitativeAttributeAccuracy>
                            </gmd:report>
                        </xsl:for-each>
                    </xsl:if>
                    <xsl:if test="lineage">
                       <gmd:lineage>
                           <gmd:LI_Lineage>
                               <xsl:for-each select="lineage/step">
                                   <gmd:processStep>
                                       <gmd:LI_ProcessStep>
                                            <gmd:description>
                                                <gco:CharacterString><xsl:value-of select="description"></xsl:value-of></gco:CharacterString>
                                            </gmd:description>
                                           
                                           <gmd:dateTime>
                                               <xsl:variable name="proc-date">
                                                   <xsl:call-template name="format-datetime">
                                                       <xsl:with-param name="datestring" select="rundate/@date"/>
                                                       <xsl:with-param name="timestring" select="if (rundate/@time) then rundate/@time else '00:00:00'"/>
                                                   </xsl:call-template>
                                               </xsl:variable>
                                               
                                               <xsl:choose>
                                                   <xsl:when test="$proc-date = 'unknown' or $proc-date = 'present'">
                                                       <xsl:attribute name="gco:nilReason" select="'unknown'"/>
                                                   </xsl:when>
                                                   <xsl:otherwise>
                                                       <gco:DateTime>
                                                           <xsl:value-of select="$proc-date"/>
                                                       </gco:DateTime>
                                                   </xsl:otherwise>
                                               </xsl:choose>
                                           </gmd:dateTime>
                                           
                                            <xsl:if test="contact[@role='responsible-party']">
                                                <gmd:processor>
                                                    <gmd:CI_ResponsibleParty>
                                                        <xsl:variable name="processing-contact-id" select="contact[@role='responsible-party']/@ref"></xsl:variable>
                                                        <xsl:apply-templates select="$all-contacts/contact[@id=$processing-contact-id]"></xsl:apply-templates>
                                                        <gmd:role>
                                                            <gmd:CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                                                                codeListValue="processor"/>
                                                        </gmd:role>
                                                    </gmd:CI_ResponsibleParty>
                                                </gmd:processor>
                                            </xsl:if>
                   
         <!--                               the source if srcused    -->
                                            <xsl:if test="source[@type='used']">
                                                <xsl:for-each select="source[@type='used']">
                                                    <gmd:source>
                                                        <gmd:LI_Source>
                                                            <gmd:sourceCitation>
                                                                <gmd:CI_Citation>
                                                                    <gmd:title>
                                                                        <xsl:variable name="processing-source-id" select="if (contains(@ref, ' ')) then substring-before(@ref, ' ') else @ref"/>
                                                                        <!--<xsl:variable name="processing-source-id" select="if (source[@type='used' and contains(@id, ' ')]) then source[@type='used']/substring-before(@id, ' ') else source[@type='used']/@id"></xsl:variable>-->
                                                                        <gco:CharacterString>
                                                                            <xsl:value-of select="$all-sources/source[@id=$processing-source-id]/alias"/>
                                                                        </gco:CharacterString>
                                                                    </gmd:title>
                                                                    <gmd:date gco:nilReason="unknown"/>
                                                                </gmd:CI_Citation>
                                                            </gmd:sourceCitation>
                                                        </gmd:LI_Source>
                                                    </gmd:source>
                                                </xsl:for-each>
                                       </xsl:if>
                                       </gmd:LI_ProcessStep>
                                   </gmd:processStep>
                               </xsl:for-each>
                               <xsl:for-each select="$all-sources/source[@type='lineage']">
                                   <gmd:source>
                                       <gmd:LI_Source>
                                        
                                            <gmd:description>
                                                <gco:CharacterString><xsl:value-of select="contribution"/></gco:CharacterString>
                                            </gmd:description>
                                            <gmd:scaleDenominator>
                                                <gmd:MD_RepresentativeFraction>
                                                    <gmd:denominator>
                                                        <xsl:choose>
                                                            <xsl:when test="not(scale)">
                                                                <xsl:attribute name="gco:nilReason" select="'unknown'"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <gco:Integer><xsl:value-of select="scale"/></gco:Integer>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </gmd:denominator>
                                                </gmd:MD_RepresentativeFraction>
                                            </gmd:scaleDenominator>
                                            <xsl:if test="citation">
                                                <xsl:variable name="src-citation-id" select="citation/@ref"/>
                                                <xsl:variable name="src-citation" select="$all-citations/citation[@id=$src-citation-id]"/>
                                                <gmd:sourceCitation>
                                                    <gmd:CI_Citation>
                                                        <gmd:title>
                                                            <gco:CharacterString><xsl:value-of select="$src-citation/title"/></gco:CharacterString>
                                                        </gmd:title>
                                                        <xsl:if test="alias">
                                                            <gmd:alternateTitle>
                                                                <gco:CharacterString>
                                                                    <xsl:value-of select="alias"/>
                                                                </gco:CharacterString>
                                                            </gmd:alternateTitle>
                                                        </xsl:if>
                                                        <xsl:choose>
                                                            <xsl:when test="$src-citation/publication/pubdate">
                                                                <gmd:date>
                                                                    <xsl:variable name="src-date">
                                                                        <xsl:call-template name="format-datetime">
                                                                            <xsl:with-param name="datestring" select="$src-citation/publication/pubdate/@date"/>
                                                                            <xsl:with-param name="timestring" select="if ($src-citation/publication/pubdate/@time) then $src-citation/publication/pubdate/@time else '00:00:00'"/>
                                                                        </xsl:call-template>
                                                                    </xsl:variable>
                                                                    <xsl:choose>
                                                                        <xsl:when test="$src-date = 'unknown' or $src-date = 'present'">
                                                                            <xsl:attribute name="gco:nilReason" select="'unknown'"/>
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                            <gmd:CI_Date>
                                                                                <gmd:date>
                                                                                    <gco:DateTime>
                                                                                          <xsl:value-of select="$src-date"/>
                                                                                      </gco:DateTime>
                                                                                </gmd:date>
                                                                               <gmd:dateType>
                                                                                   <gmd:CI_DateTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode"
                                                                                       codeListValue="publication"/>
                                                                               </gmd:dateType>
                                                                            </gmd:CI_Date>
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                </gmd:date>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <gmd:date gco:nilReason="unknown"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                        
                                                        <gmd:citedResponsibleParty>
                                                            <gmd:CI_ResponsibleParty>
                                                                <gmd:organisationName>
                                                                    <gco:CharacterString>
                                                                        <xsl:value-of select="$src-citation/origin"/>
                                                                    </gco:CharacterString>
                                                                </gmd:organisationName>
                                                                <gmd:role>
                                                                    <gmd:CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                                                                        codeListValue="resourceProvider"/>
                                                                </gmd:role>
                                                            </gmd:CI_ResponsibleParty>
                                                        </gmd:citedResponsibleParty>
                                                        <!--<xsl:if test="$src-citation/geoform">
                                                            <!-\- TODO: change this to an actual iso thing -\->
                                                            <gmd:presentationForm>
                                                                <gmd:CI_PresentationFormCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_PresentationFormCode"
                                                                    codeListValue="modelDigital"><xsl:value-of select="$src-citation/geoform"/></gmd:CI_PresentationFormCode>
                                                            </gmd:presentationForm>
                                                        </xsl:if>-->
                                                    </gmd:CI_Citation>
                                                </gmd:sourceCitation>
                                            </xsl:if>
                                            <xsl:if test="srcdate">
                                                <gmd:sourceExtent>
                                                    <xsl:choose>
                                                        <xsl:when test="srcdate/range">
                                                            <gmd:EX_Extent>
                                                                <gmd:temporalElement>
                                                                    <gmd:EX_TemporalExtent>
                                                                        <gmd:extent>
                                                                              <gml:TimePeriod gml:id="{generate-id(.)}">
                                                                                  <gml:description>
                                                                                      <xsl:value-of select="current"/>
                                                                                  </gml:description>
                                                                                  <gml:beginPosition>
                                                                                      <xsl:variable name="begin-pos">
                                                                                            <xsl:value-of>
                                                                                                <xsl:call-template name="format-datetime">
                                                                                                    <xsl:with-param name="datestring" select="srcdate/range/start/@date"/>
                                                                                                    <xsl:with-param name="timestring" select="srcdate/range/start/@time"/>
                                                                                                </xsl:call-template>
                                                                                            </xsl:value-of>
                                                                                      </xsl:variable>
                                                                                      <xsl:choose>
                                                                                          <xsl:when test="$begin-pos = 'unknown'">
                                                                                              <xsl:attribute name="indeterminatePosition" select="'unknown'"/>
                                                                                          </xsl:when>
                                                                                          <xsl:otherwise>
                                                                                              <xsl:value-of select="$begin-pos"/>
                                                                                          </xsl:otherwise>
                                                                                      </xsl:choose>
                                                                                  </gml:beginPosition>
                                                                                  <gml:endPosition>
                                                                                      <xsl:variable name="end-pos">
                                                                                          <xsl:value-of>
                                                                                              <xsl:call-template name="format-datetime">
                                                                                                  <xsl:with-param name="datestring" select="srcdate/range/end/@date"/>
                                                                                                  <xsl:with-param name="timestring" select="srcdate/range/end/@time"/>
                                                                                              </xsl:call-template>
                                                                                          </xsl:value-of>
                                                                                      </xsl:variable>
                                                                                      <xsl:choose>
                                                                                          <xsl:when test="$end-pos = 'unknown'">
                                                                                              <xsl:attribute name="indeterminatePosition" select="'unknown'"/>
                                                                                          </xsl:when>
                                                                                          <xsl:otherwise>
                                                                                              <xsl:value-of select="$end-pos"/>
                                                                                          </xsl:otherwise>
                                                                                      </xsl:choose>
                                                                                  </gml:endPosition>
                                                                              </gml:TimePeriod>
                                                                        </gmd:extent>
                                                                    </gmd:EX_TemporalExtent>
                                                                </gmd:temporalElement>
                                                            </gmd:EX_Extent>
                                                        </xsl:when>
                                                        <xsl:when test="fn:count(srcdate/single) > 1">
                                                            <gmd:EX_Extent>
                                                                <xsl:for-each select="srcdate/single">
                                                                    <gmd:temporalElement>
                                                                        <gmd:EX_TemporalExtent>
                                                                            <gmd:extent>
                                                                                <gml:TimeInstant gml:id="{generate-id(.)}">
                                                                                    <gml:description>
                                                                                        <xsl:value-of select="../../current"/>
                                                                                    </gml:description>
                                                                                    <gml:timePosition>
                                                                                        <xsl:variable name="sng-date">
                                                                                            <xsl:call-template name="format-datetime">
                                                                                                <xsl:with-param name="datestring" select="@date"/>
                                                                                                <xsl:with-param name="timestring" select="@time"/>
                                                                                            </xsl:call-template>
                                                                                        </xsl:variable>
                                                                                        <xsl:choose>
                                                                                            <xsl:when test="$sng-date = 'unknown'">
                                                                                                <xsl:attribute name="indeterminatePosition" select="'unknown'"/>
                                                                                            </xsl:when>
                                                                                            <xsl:otherwise>
                                                                                                <xsl:value-of select="$sng-date"/>
                                                                                            </xsl:otherwise>
                                                                                        </xsl:choose>
                                                                                    </gml:timePosition>
                                                                                </gml:TimeInstant>
                                                                            </gmd:extent>
                                                                        </gmd:EX_TemporalExtent>
                                                                    </gmd:temporalElement>
                                                                </xsl:for-each>
                                                            </gmd:EX_Extent>
                                                        </xsl:when>
                                                        <xsl:when test="fn:count(srcdate/single) = 1">
                                                            <gmd:EX_Extent>
                                                                <gmd:temporalElement>
                                                                    <gmd:EX_TemporalExtent>
                                                                        <gmd:extent>
                                                                            <gml:TimeInstant gml:id="{generate-id(srcdate/single)}">
                                                                                <gml:description>
                                                                                    <xsl:value-of select="current"/>
                                                                                </gml:description>
                                                                                <gml:timePosition>
                                                                                    <xsl:variable name="sng-date">
                                                                                        <xsl:call-template name="format-datetime">
                                                                                            <xsl:with-param name="datestring" select="srcdate/single/@date"/>
                                                                                            <xsl:with-param name="timestring" select="srcdate/single/@time"/>
                                                                                        </xsl:call-template>
                                                                                    </xsl:variable>
                                                                                    <xsl:choose>
                                                                                        <xsl:when test="$sng-date = 'unknown'">
                                                                                            <xsl:attribute name="indeterminatePosition" select="'unknown'"/>
                                                                                        </xsl:when>
                                                                                        <xsl:otherwise>
                                                                                            <xsl:value-of select="$sng-date"/>
                                                                                        </xsl:otherwise>
                                                                                    </xsl:choose>
                                                                                </gml:timePosition>
                                                                            </gml:TimeInstant>
                                                                        </gmd:extent>
                                                                    </gmd:EX_TemporalExtent>
                                                                </gmd:temporalElement>
                                                            </gmd:EX_Extent>
                                                        </xsl:when>
                                                    </xsl:choose>     
                                                </gmd:sourceExtent>
                                            </xsl:if>
                                       </gmd:LI_Source>
                                   </gmd:source>
                               </xsl:for-each>
                           </gmd:LI_Lineage>
                       </gmd:lineage>
                   </xsl:if>
               </gmd:DQ_DataQuality>
           </gmd:dataQualityInfo>
           <gmd:metadataMaintenance>
               <gmd:MD_MaintenanceInformation>
                <gmd:maintenanceAndUpdateFrequency gco:nilReason="unknown"/>
                <xsl:if test="metadata/contact[@role='point-contact']">
                   <xsl:variable name="metadata-contact-id" select="metadata/contact[@role='point-contact']/@ref"/>
                   <xsl:variable name="metadata-contact" select="$all-contacts/contact[@id=$metadata-contact-id]"/>
                   
                   <gmd:contact>
                       <gmd:CI_ResponsibleParty>
                           
                           <xsl:if test="$metadata-contact/organization">
                               <gmd:organisationName>
                                   <gco:CharacterString>
                                       <xsl:value-of select="$metadata-contact/organization/name"/>
                                   </gco:CharacterString>
                               </gmd:organisationName>
                           </xsl:if>
                           <xsl:if test="$metadata-contact/position">
                               <gmd:positionName>
                                   <gco:CharacterString>
                                       <xsl:value-of select="$metadata-contact/position"/>
                                   </gco:CharacterString>
                               </gmd:positionName>
                           </xsl:if>
                           <gmd:contactInfo>
                               <gmd:CI_Contact>
                                   <xsl:if test="$metadata-contact/voice or $metadata-contact/fax">
                                       <gmd:phone>
                                           <gmd:CI_Telephone>
                                               <xsl:if test="$metadata-contact/voice">
                                                   <gmd:voice>
                                                       <gco:CharacterString><xsl:value-of select="$metadata-contact/voice"/></gco:CharacterString>
                                                   </gmd:voice>
                                               </xsl:if>
                                               <xsl:if test="$metadata-contact/fax">
                                                   <gmd:facsimile>
                                                       <gco:CharacterString><xsl:value-of select="$metadata-contact/fax"/></gco:CharacterString>
                                                   </gmd:facsimile>
                                               </xsl:if>
                                           </gmd:CI_Telephone>
                                       </gmd:phone>
                                   </xsl:if>
                                   
                                   <!-- TODO: add support for multiple addresses! -->
                                   <gmd:address>
                                       <gmd:CI_Address>
                                           <xsl:for-each select="$metadata-contact/address/addr">
                                               <gmd:deliveryPoint>
                                                   <gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
                                               </gmd:deliveryPoint>
                                           </xsl:for-each>
                                           <gmd:city>
                                               <gco:CharacterString><xsl:value-of select="$metadata-contact/address/city"/></gco:CharacterString>
                                           </gmd:city>
                                           <gmd:administrativeArea>
                                               <gco:CharacterString><xsl:value-of select="$metadata-contact/address/state"/></gco:CharacterString>
                                           </gmd:administrativeArea>
                                           <gmd:postalCode>
                                               <gco:CharacterString><xsl:value-of select="$metadata-contact/address/postal"/></gco:CharacterString>
                                           </gmd:postalCode>
                                           <gmd:country>
                                               <gco:CharacterString><xsl:value-of select="$metadata-contact/address/country"/></gco:CharacterString>
                                           </gmd:country>
                                           <xsl:if test="$metadata-contact/email">
                                               <gmd:electronicMailAddress>
                                                   <gco:CharacterString><xsl:value-of select="$metadata-contact/email"/></gco:CharacterString>
                                               </gmd:electronicMailAddress>
                                           </xsl:if>
                                       </gmd:CI_Address>
                                   </gmd:address>
                                   <xsl:if test="$metadata-contact/hours">
                                       <gmd:hoursOfService>
                                           <gco:CharacterString><xsl:value-of select="$metadata-contact/hours"/></gco:CharacterString>
                                       </gmd:hoursOfService>
                                   </xsl:if>
                                   <xsl:if test="$metadata-contact/instructions">
                                       <gmd:contactInstructions>
                                           <gco:CharacterString><xsl:value-of select="$metadata-contact/instructions"/></gco:CharacterString>
                                       </gmd:contactInstructions>
                                   </xsl:if>
                               </gmd:CI_Contact>
                           </gmd:contactInfo>
                           <gmd:role>
                               <gmd:CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                                   codeListValue="custodian">custodian</gmd:CI_RoleCode>
                           </gmd:role>
                       </gmd:CI_ResponsibleParty>
                   </gmd:contact>
               </xsl:if>
               </gmd:MD_MaintenanceInformation>
           </gmd:metadataMaintenance>
       </gmi:MI_Metadata>
   </xsl:template>
    
    <xsl:template name="generate-timeExtent">
<!--    flags to be single, start, or end
        also this is just the one element with the datetime string and NOT the full structure
        
        timePosition or beginPosition or endPosition
        
        timestamp = yyyy-mm-dd | yyyy-mm-ddThh:mm:ss.sss+zz:zz | unknown | present
-->
        <xsl:param name="tag-type"></xsl:param>
        <xsl:param name="datestring" select="()"></xsl:param>
        <xsl:param name="timestring" select="()"></xsl:param>
        
        <xsl:variable name="timestamp">
            <xsl:call-template name="format-datetime">
                <xsl:with-param name="datestring" select="$datestring"></xsl:with-param>
                <xsl:with-param name="timestring" select="$timestring"></xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$tag-type='single'">
                <gml:timePosition>
                    <xsl:choose>
                        <xsl:when test="$timestamp='present'">
                            <xsl:attribute name="indeterminatePosition" select="'now'"></xsl:attribute>
                            <xsl:value-of select="fn:current-dateTime()"></xsl:value-of>
                        </xsl:when>
                        <xsl:when test="$timestamp='unknown'">
                            <xsl:attribute name="indeterminatePosition" select="'unknown'"></xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$timestamp"></xsl:value-of>
                        </xsl:otherwise>
                    </xsl:choose>
                </gml:timePosition>
            </xsl:when>
            <xsl:when test="$tag-type='begin'">
                <gml:beginPosition>
                    <xsl:choose>
                        <xsl:when test="$timestamp='present'">
                            <xsl:attribute name="indeterminatePosition" select="'now'"></xsl:attribute>
                            <xsl:value-of select="fn:current-dateTime()"></xsl:value-of>
                        </xsl:when>
                        <xsl:when test="$timestamp='unknown'">
                            <xsl:attribute name="indeterminatePosition" select="'unknown'"></xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$timestamp"></xsl:value-of>
                        </xsl:otherwise>
                    </xsl:choose>
                </gml:beginPosition>
            </xsl:when>
            <xsl:when test="$tag-type='end'">
                <gml:endPosition>
                    <xsl:choose>
                        <xsl:when test="$timestamp='present'">
                            <xsl:attribute name="indeterminatePosition" select="'now'"></xsl:attribute>
                            <xsl:value-of select="fn:current-dateTime()"></xsl:value-of>
                        </xsl:when>
                        <xsl:when test="$timestamp='unknown'">
                            <xsl:attribute name="indeterminatePosition" select="'unknown'"></xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$timestamp"></xsl:value-of>
                        </xsl:otherwise>
                    </xsl:choose>
                </gml:endPosition>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="format-datetime">
        <xsl:param name="datestring" select="()"/>
        <xsl:param name="timestring" select="()"/>
        
        <!-- this just builds the string, not the element with the string (you still need to do whatever unknown, etc, checks)		-->
        <xsl:choose>
            <xsl:when test="fn:contains(fn:lower-case($datestring), 'present')">
                <!-- to act as a trigger for any now() generated datetime -->
                <xsl:value-of select="'present'"/>
            </xsl:when>
            <xsl:when test="(fn:contains(fn:lower-case(fn:normalize-space($datestring)), 'unknown') or fn:contains(fn:lower-case(fn:normalize-space($datestring)), 'unpublished') or fn:contains(fn:lower-case(fn:string($datestring)), 'not complete'))">
                <!-- just unknown from this -->
                <xsl:value-of select="'unknown'"/>
            </xsl:when>
            <xsl:otherwise>
                
                <xsl:variable name="date-parts" select="fn:tokenize($datestring, '-')"/>
                
                <!-- we have a date/datetime, fingers crossed -->
                <xsl:variable name="year">
                    <xsl:value-of select="$date-parts[1]"/>
                </xsl:variable>
                <xsl:variable name="month">
                    <xsl:choose>
                        <xsl:when test="fn:count($date-parts) > 1">
                            <xsl:value-of select="$date-parts[2]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'01'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="day">
                    <xsl:choose>
                        <xsl:when test="fn:count($date-parts) > 2">
                            <xsl:value-of select="$date-parts[3]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'01'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:choose>
                    <xsl:when test="$datestring and (not($timestring) or fn:contains(fn:lower-case($timestring), 'unknown'))">
                        <!-- we only have the date-->
                        <xsl:value-of select="$year[text() != ''] | $month[text() != ''] | $day[text() != '']" separator="-"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- we should have a good date and time and the time can't be anything less than HH:mm:ss from gstore-->
                        <!-- generate the new date structure-->
                        <xsl:variable name="new-date">
                            <xsl:value-of select="$year[text() != ''] | $month[text() != ''] | $day[text() != '']" separator="-"/>
                        </xsl:variable>
                        
                        <xsl:value-of select="fn:concat($new-date, 'T', $timestring)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template match="contact">
<!--    TODO: double-check this (maybe it's the cntperp/person instead?    -->
        <xsl:if test="organization/person">
            <gmd:individualName>
                <gco:CharacterString><xsl:value-of select="organization/person"></xsl:value-of></gco:CharacterString>
            </gmd:individualName>
        </xsl:if>
        <xsl:if test="organization">
            <gmd:organisationName>
                <gco:CharacterString><xsl:value-of select="organization/name"></xsl:value-of></gco:CharacterString>
            </gmd:organisationName>
        </xsl:if>
        <xsl:if test="position">
            <gmd:positionName>
                <gco:CharacterString><xsl:value-of select="position"></xsl:value-of></gco:CharacterString>
            </gmd:positionName>
        </xsl:if>
        <gmd:contactInfo>
            <gmd:CI_Contact>
                <xsl:if test="voice or fax">
                    <gmd:phone>
                        <gmd:CI_Telephone>
                            <xsl:if test="voice">
                                <gmd:voice>
                                    <gco:CharacterString><xsl:value-of select="voice"></xsl:value-of></gco:CharacterString>
                                </gmd:voice>
                            </xsl:if>
                            <xsl:if test="fax">
                                <gmd:facsimile>
                                    <gco:CharacterString><xsl:value-of select="fax"></xsl:value-of></gco:CharacterString>
                                </gmd:facsimile>
                            </xsl:if>
                        </gmd:CI_Telephone>
                    </gmd:phone>
                </xsl:if>
                <xsl:if test="address">
                    <gmd:address>
                        <gmd:CI_Address>
                            <xsl:for-each select="address/addr">
                                <gmd:deliveryPoint>
                                    <gco:CharacterString><xsl:value-of select="."></xsl:value-of></gco:CharacterString>
                                </gmd:deliveryPoint>
                            </xsl:for-each>
                            <gmd:city>
                                <gco:CharacterString><xsl:value-of select="address/city"></xsl:value-of></gco:CharacterString>
                            </gmd:city>
                            <gmd:administrativeArea>
                                <gco:CharacterString><xsl:value-of select="address/state"></xsl:value-of></gco:CharacterString>
                            </gmd:administrativeArea>
                            <gmd:postalCode>
                                <gco:CharacterString><xsl:value-of select="address/postal"></xsl:value-of></gco:CharacterString>
                            </gmd:postalCode>
                            <xsl:if test="address/country">
                                <gmd:country>
                                    <gco:CharacterString><xsl:value-of select="address/country"></xsl:value-of></gco:CharacterString>
                                </gmd:country>
                            </xsl:if>
                            <xsl:if test="email">
                                <gmd:electronicMailAddress>
                                    <gco:CharacterString><xsl:value-of select="email"></xsl:value-of></gco:CharacterString>
                                </gmd:electronicMailAddress>
                            </xsl:if>
                        </gmd:CI_Address>
                    </gmd:address>
                </xsl:if>
                <xsl:if test="hours">
                    <gmd:hoursOfService>
                        <gco:CharacterString><xsl:value-of select="hours"></xsl:value-of></gco:CharacterString>
                    </gmd:hoursOfService>
                </xsl:if>
                <xsl:if test="instructions">
                    <gmd:contactInstructions>
                        <gco:CharacterString><xsl:value-of select="instructions"></xsl:value-of></gco:CharacterString>
                    </gmd:contactInstructions>
                </xsl:if>
            </gmd:CI_Contact>
        </gmd:contactInfo>
            
    </xsl:template>
    <xsl:template match="citation">
        
    </xsl:template>
    <xsl:template match="source">
        
    </xsl:template>
</xsl:stylesheet>