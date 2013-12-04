<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:gco="http://www.isotc211.org/2005/gco" 
    xmlns:gmd="http://www.isotc211.org/2005/gmd" 
    xmlns:gmi="http://www.isotc211.org/2005/gmi" 
    xmlns:gmx="http://www.isotc211.org/2005/gmx" 
    xmlns:gsr="http://www.isotc211.org/2005/gsr" 
    xmlns:gss="http://www.isotc211.org/2005/gss" 
    xmlns:gts="http://www.isotc211.org/2005/gts" 
    xmlns:gml="http://www.opengis.net/gml/3.2" 
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"  
    xmlns:fn="http://www.w3.org/2005/xpath-functions" 
    exclude-result-prefixes="fn xs xsi xsl" xmlns="http://www.isotc211.org/2005/gmi">
    <xsl:output indent="yes"/>
    
    <xsl:param name="app" select="'RGIS'"/>
    
    <xsl:variable name="all-citations" select="/metadata/citations"></xsl:variable>
    <xsl:variable name="all-contacts" select="/metadata/contacts"></xsl:variable>
    
    <xsl:template match="/metadata">
        <gmd:DS_Series>
            <xsl:attribute name="xsi:schemaLocation" select="'http://www.isotc211.org/2005/gmi http://www.ngdc.noaa.gov/metadata/published/xsd/schema.xsd'"></xsl:attribute>
            
            <!-- add the links to all of the dataset iso records -->
            <gmd:composedOf>
                <gmd:DS_DataSet>
                    <xsl:for-each select="datasets/dataset">
                        <gmd:has xlink:href="{.}"/>
                    </xsl:for-each>
                    <!-- TODO: add structure for basic MI record if gstore dataset doesn't support iso -->
                </gmd:DS_DataSet>
            </gmd:composedOf>
            
            <gmd:seriesMetadata>
                <gmi:MI_Metadata>
                    <gmd:fileIdentifier>
                        <gco:CharacterString>
                            <xsl:value-of select="fn:concat(fn:upper-case($app), '::', identification/@identifier, '::ISO-19115:DS')"/>
                        </gco:CharacterString>
                    </gmd:fileIdentifier>
                    
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
                        <!-- from the metadata timestamp    -->
                        
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
                    
                    <gmd:dataSetURI>
                        <gco:CharacterString><xsl:value-of select="identification/@identifier"/></gco:CharacterString>
                    </gmd:dataSetURI>
                    
                    <gmd:identificationInfo>
                        <gmd:MD_DataIdentification>
                            <xsl:variable name="id-citation-id" select="identification/citation[@role='identify']/@ref"/>
                            <xsl:variable name="id-citation" select="$all-citations/citation[@id=$id-citation-id]"/>
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
                            
                            <gmd:pointOfContact>
                                <gmd:CI_ResponsibleParty>
                                    <xsl:apply-templates select="$all-contacts/contact[@id=$identity-ptcontac-id]"/>
                                    <gmd:role>
                                        <xsl:variable name="rolecode">
                                            <xsl:choose>
                                                <xsl:when test="identification/contact[@role='point-contact']">
                                                    <xsl:value-of select="'pointOfContact'"/>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:variable>
                                        <gmd:CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                                            codeListValue="{$rolecode}"/>
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
                            
                            <gmd:language>
                                <gco:CharacterString>eng; USA</gco:CharacterString>
                            </gmd:language>
                            
                            <xsl:if test="identification/isotopic">
                                <gmd:topicCategory>
                                    <gmd:MD_TopicCategoryCode><xsl:value-of select="identification/isotopic"></xsl:value-of></gmd:MD_TopicCategoryCode>
                                </gmd:topicCategory>
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
                            
                        </gmd:MD_DataIdentification>
                    </gmd:identificationInfo>
                    
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
            </gmd:seriesMetadata>
            
        </gmd:DS_Series>
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
    
</xsl:stylesheet>