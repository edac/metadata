<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:gss="http://www.isotc211.org/2005/gss"
    xmlns:gts="http://www.isotc211.org/2005/gts"
    xmlns:gml="http://www.opengis.net/gml/3.2"
    xmlns:srv="http://www.isotc211.org/2005/srv"
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
    
    <xsl:param name="app" select="'RGIS'"/>
    
    <xsl:param name="service-type" select="'wms'"/>
    <xsl:param name="service-version" select="'1.1.1'"/>
    <xsl:param name="service-base-url" select="''"/>
    
    <xsl:variable name="all-contacts" select="/metadata/contacts"></xsl:variable>
    <xsl:variable name="all-citations" select="/metadata/citations"></xsl:variable>
    
    <xsl:variable name="service-link" select="fn:concat($service-base-url, '/', fn:lower-case($service-type), '?')"></xsl:variable>
    
    <xsl:template match="/metadata">
        <gmd:MD_Metadata>
            <xsl:attribute name="xsi:schemaLocation" select="'http://www.isotc211.org/2005/gmi http://www.ngdc.noaa.gov/metadata/published/xsd/schema.xsd'"/>
            
            <gmd:fileIdentifier>
                <gco:CharacterString><xsl:value-of select="fn:concat(fn:upper-case($app), '::', identification/@dataset, '::ISO-19119:', fn:upper-case($service-type))"/></gco:CharacterString>
            </gmd:fileIdentifier>
            
            <gmd:language>
                <gco:CharacterString>eng; USA</gco:CharacterString>
            </gmd:language>
            <gmd:characterSet>
                <gmd:MD_CharacterSetCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_CharacterSetCode" codeListValue="utf8"/>
            </gmd:characterSet>
            <gmd:hierarchyLevel>
                <gmd:MD_ScopeCode codeSpace="ISOTC211/19115" codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_ScopeCode" codeListValue="service"/>
            </gmd:hierarchyLevel>
            
            <!-- get the metadata contact -->
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
                            codeListValue="publisher">publisher</gmd:CI_RoleCode>
                    </gmd:role>
                </gmd:CI_ResponsibleParty>
            </gmd:contact>
            
            <gmd:dateStamp>
                <xsl:call-template name="generate-dateElement">
                    <xsl:with-param name="datestring" select="metadata/pubdate/@date"></xsl:with-param>
                    <xsl:with-param name="timestring" select="metadata/pubdate/@time"></xsl:with-param>
                    <xsl:with-param name="tag-type" select="if (metadata/pubdate/@time) then 'datetimestamp' else 'datestamp'"></xsl:with-param>
                </xsl:call-template>
            </gmd:dateStamp>
            
            <gmd:metadataStandardName>
                <gco:CharacterString>ISO 19139/19119 Metadata for Web Services</gco:CharacterString>
            </gmd:metadataStandardName>
            <gmd:metadataStandardVersion>
                <gco:CharacterString>2005</gco:CharacterString>
            </gmd:metadataStandardVersion>
            
            <!-- service identification -->
            <gmd:identificationInfo>
                <srv:SV_ServiceIdentification>
                    <gmd:citation>
                        <gmd:CI_Citation>
                            <gmd:title>
                                <gco:CharacterString>
                                    <xsl:value-of select="identification/title"/>
                                </gco:CharacterString>
                            </gmd:title>
                            <xsl:variable name="id-citation-id" select="identification/citation[@role='identify']/@ref"></xsl:variable>
                            <xsl:variable name="id-citation" select="$all-citations/citation[@id=$id-citation-id]"></xsl:variable>
                            <xsl:choose>
                                <xsl:when test="$id-citation/publication/pubdate">
                                    <xsl:variable name="date" select="$id-citation/publication/pubdate/@date"/>
                                    <xsl:variable name="time" select="$id-citation/publication/pubdate/@time"/>
                                    
                                    <!-- TODO: figure out why this is unknown -->
                                    <xsl:choose>
                                        <xsl:when test="$date != 'Unknown' and $time != 'Unknown'">
                                            <gmd:date>
                                                <gmd:CI_Date>
                                                    <gmd:date>
                                                        <gco:DateTime><xsl:value-of select="fn:concat($date, 'T', $time)"/></gco:DateTime>
                                                    </gmd:date>
                                                    <gmd:dateType>
                                                        <gmd:CI_DateTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode"
                                                            codeListValue="publication">publication</gmd:CI_DateTypeCode>
                                                    </gmd:dateType>
                                                </gmd:CI_Date>
                                            </gmd:date>
                                        </xsl:when>
                                        <xsl:when test="$date != 'Unknown' and ($time = 'Unknown' or not($time))">
                                            <gmd:date>
                                                <gmd:CI_Date>
                                                    <gmd:date>
                                                        <gco:Date><xsl:value-of select="$date"/></gco:Date>
                                                    </gmd:date>
                                                    <gmd:dateType>
                                                        <gmd:CI_DateTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode"
                                                            codeListValue="publication">publication</gmd:CI_DateTypeCode>
                                                    </gmd:dateType>
                                                </gmd:CI_Date>
                                            </gmd:date>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <gmd:date gco:nilReason="unknown"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <gmd:date gco:nilReason="unknown"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </gmd:CI_Citation>
                    </gmd:citation>
                    
                    <gmd:abstract>
                        <gco:CharacterString><xsl:value-of select="identification/abstract"/></gco:CharacterString>
                    </gmd:abstract>
                    
                    <xsl:variable name="identity-ptcontac-id" select="identification/contact[@role='point-contact']/@ref"/>
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
                    
                    <!-- SERVICE DESCRIPTION -->
                    <srv:serviceType>
                        <gco:LocalName>
                            <xsl:choose>
                                <xsl:when test="fn:lower-case($service-type) = 'wms' or fn:lower-case($service-type) = 'wfs' or fn:lower-case($service-type) = 'wcs'">
                                    <xsl:value-of select="fn:concat('OGC:', fn:upper-case($service-type))"></xsl:value-of>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="'Unknown'"></xsl:value-of>
                                </xsl:otherwise>
                            </xsl:choose>
                        </gco:LocalName>
                    </srv:serviceType>
                    <srv:serviceTypeVersion>
                        <gco:CharacterString>
                            <xsl:value-of select="$service-version"/>
                        </gco:CharacterString>
                    </srv:serviceTypeVersion>
                    
                    <srv:extent>
                        <gmd:EX_Extent id="boundingExtent">
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
                    </srv:extent>
                    
                    <srv:couplingType>
                        <!-- this codelist doesn't seem to exist  -->
                        <srv:SV_CouplingType codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#SV_CouplingType" codeListValue="mixed"></srv:SV_CouplingType>
                    </srv:couplingType>
                    
                    <!-- OGC GetCapabilities -->
                    <srv:containsOperations>
                        <srv:SV_OperationMetadata>
                            <srv:operationName>
                                <gco:CharacterString>GetCapabilities</gco:CharacterString>
                            </srv:operationName>
                            <srv:DCP>
                                <!-- this codelist is also unknown -->
                                <srv:DCPList codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#DCPList" codeListValue="HTTPGet"></srv:DCPList>
                            </srv:DCP>
                            
                            <!-- one+ parameters -->
                            <srv:parameters>
                                <srv:SV_Parameter>
                                    <srv:name>
                                        <gco:aName>
                                            <gco:CharacterString>Service</gco:CharacterString>
                                        </gco:aName>
                                        <gco:attributeType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </gco:attributeType>
                                    </srv:name>
                                    <srv:direction>
                                        <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                    </srv:direction>
                                    <srv:optionality>
                                        <gco:CharacterString>Mandatory</gco:CharacterString>
                                    </srv:optionality>
                                    <srv:repeatability>
                                        <gco:Boolean>false</gco:Boolean>
                                    </srv:repeatability>
                                    <srv:valueType>
                                        <gco:TypeName>
                                            <gco:aName>
                                                <gco:CharacterString>String</gco:CharacterString>
                                            </gco:aName>
                                        </gco:TypeName>
                                    </srv:valueType>
                                </srv:SV_Parameter>
                            </srv:parameters>
                            <srv:parameters>
                                <srv:SV_Parameter>
                                    <srv:name>
                                        <gco:aName>
                                            <gco:CharacterString>Version</gco:CharacterString>
                                        </gco:aName>
                                        <gco:attributeType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </gco:attributeType>
                                    </srv:name>
                                    <srv:direction>
                                        <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                    </srv:direction>
                                    <srv:optionality>
                                        <gco:CharacterString>Mandatory</gco:CharacterString>
                                    </srv:optionality>
                                    <srv:repeatability>
                                        <gco:Boolean>false</gco:Boolean>
                                    </srv:repeatability>
                                    <srv:valueType>
                                        <gco:TypeName>
                                            <gco:aName>
                                                <gco:CharacterString>String</gco:CharacterString>
                                            </gco:aName>
                                        </gco:TypeName>
                                    </srv:valueType>
                                </srv:SV_Parameter>
                            </srv:parameters>
                            <srv:parameters>
                                <srv:SV_Parameter>
                                    <srv:name>
                                        <gco:aName>
                                            <gco:CharacterString>Request</gco:CharacterString>
                                        </gco:aName>
                                        <gco:attributeType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </gco:attributeType>
                                    </srv:name>
                                    <srv:direction>
                                        <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                    </srv:direction>
                                    <srv:optionality>
                                        <gco:CharacterString>Mandatory</gco:CharacterString>
                                    </srv:optionality>
                                    <srv:repeatability>
                                        <gco:Boolean>false</gco:Boolean>
                                    </srv:repeatability>
                                    <srv:valueType>
                                        <gco:TypeName>
                                            <gco:aName>
                                                <gco:CharacterString>String</gco:CharacterString>
                                            </gco:aName>
                                        </gco:TypeName>
                                    </srv:valueType>
                                </srv:SV_Parameter>
                            </srv:parameters>
                            
                            <!-- service link -->
                            <srv:connectPoint>
                                <gmd:CI_OnlineResource>
                                    <gmd:linkage>
                                        <gmd:URL>
                                            <xsl:value-of select="$service-link"/>
                                        </gmd:URL>
                                    </gmd:linkage>
                                </gmd:CI_OnlineResource>
                            </srv:connectPoint>
                        </srv:SV_OperationMetadata>
                    </srv:containsOperations>
                    
                    <!-- request-specific methods -->
                    <xsl:if test="fn:lower-case($service-type)='wms'">
                        <!-- GETMAP -->
                        <srv:containsOperations>
                            <srv:SV_OperationMetadata>
                                <srv:operationName>
                                    <gco:CharacterString>GetMap</gco:CharacterString>
                                </srv:operationName>
                                <srv:DCP>
                                    <!-- this codelist is also unknown -->
                                    <srv:DCPList codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#DCPList" codeListValue="HTTPGet"></srv:DCPList>
                                </srv:DCP>
                                
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Service</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Version</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Request</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Layers</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Styles</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>SRS</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>BBOX</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Width</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Height</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Format</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                
                                <!-- service link -->
                                <srv:connectPoint>
                                    <gmd:CI_OnlineResource>
                                        <gmd:linkage>
                                            <gmd:URL>
                                                <xsl:value-of select="$service-link"/>
                                            </gmd:URL>
                                        </gmd:linkage>
                                    </gmd:CI_OnlineResource>
                                </srv:connectPoint>
                            </srv:SV_OperationMetadata>
                        </srv:containsOperations>
                        <!-- GETFEATUREINFO -->
                        <srv:containsOperations>
                            <srv:SV_OperationMetadata>
                                <srv:operationName>
                                    <gco:CharacterString>GetFeatureInfo</gco:CharacterString>
                                </srv:operationName>
                                <srv:DCP>
                                    <!-- this codelist is also unknown -->
                                    <srv:DCPList codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#DCPList" codeListValue="HTTPGet"></srv:DCPList>
                                </srv:DCP>
                                
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Service</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Version</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Request</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Layers</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Styles</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>SRS</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>BBOX</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Width</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Height</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Query_layers</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>info_format</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Optional</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>feature_count</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>optional</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>x or i</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Optional</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>y or j</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Optional</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>exceptions</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Optional</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                
                                <!-- service link -->
                                <srv:connectPoint>
                                    <gmd:CI_OnlineResource>
                                        <gmd:linkage>
                                            <gmd:URL>
                                                <xsl:value-of select="$service-link"/>
                                            </gmd:URL>
                                        </gmd:linkage>
                                    </gmd:CI_OnlineResource>
                                </srv:connectPoint>
                            </srv:SV_OperationMetadata>
                        </srv:containsOperations>
                        <!-- DESCRIBELAYER -->
                        <srv:containsOperations>
                            <srv:SV_OperationMetadata>
                                <srv:operationName>
                                    <gco:CharacterString>DescribeLayer</gco:CharacterString>
                                </srv:operationName>
                                <srv:DCP>
                                    <!-- this codelist is also unknown -->
                                    <srv:DCPList codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#DCPList" codeListValue="HTTPGet"></srv:DCPList>
                                </srv:DCP>
                                
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Service</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Version</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Request</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Layers</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Exceptions</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Optional</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                
                                <!-- service link -->
                                <srv:connectPoint>
                                    <gmd:CI_OnlineResource>
                                        <gmd:linkage>
                                            <gmd:URL>
                                                <xsl:value-of select="$service-link"/>
                                            </gmd:URL>
                                        </gmd:linkage>
                                    </gmd:CI_OnlineResource>
                                </srv:connectPoint>
                            </srv:SV_OperationMetadata>
                        </srv:containsOperations>
                        <!-- GETLEGENDGRAPHIC -->
                        <srv:containsOperations>
                            <srv:SV_OperationMetadata>
                                <srv:operationName>
                                    <gco:CharacterString>GetLegendGraphic</gco:CharacterString>
                                </srv:operationName>
                                <srv:DCP>
                                    <!-- this codelist is also unknown -->
                                    <srv:DCPList codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#DCPList" codeListValue="HTTPGet"></srv:DCPList>
                                </srv:DCP>
                                
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Service</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Version</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Request</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Layers</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Format</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Width</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Optional</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Height</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Optional</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>SLD</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Optional</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>SLD_Body</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Optional</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>SLD_Version</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Optional</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Scale</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Optional</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Style</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Optional</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Rule</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Optional</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>

                                
                                <!-- service link -->
                                <srv:connectPoint>
                                    <gmd:CI_OnlineResource>
                                        <gmd:linkage>
                                            <gmd:URL>
                                                <xsl:value-of select="$service-link"/>
                                            </gmd:URL>
                                        </gmd:linkage>
                                    </gmd:CI_OnlineResource>
                                </srv:connectPoint>
                            </srv:SV_OperationMetadata>
                        </srv:containsOperations>
                    </xsl:if>
                    
                    <xsl:if test="fn:lower-case($service-type)='wfs'">
                        <!-- GETFEATURETYPE - not currently running in gstore -->
                        <!--<srv:containsOperations>
                            <srv:SV_OperationMetadata>
                                <srv:operationName>
                                    <gco:CharacterString>GetFeatureType</gco:CharacterString>
                                </srv:operationName>
                                <srv:DCP>
                                    <!-\- this codelist is also unknown -\->
                                    <srv:DCPList codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#DCPList" codeListValue="HTTPGet"></srv:DCPList>
                                </srv:DCP>
                                
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Service</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Version</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Request</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                
                                
                                <!-\- service link -\->
                                <srv:connectPoint>
                                    <gmd:CI_OnlineResource>
                                        <gmd:linkage>
                                            <gmd:URL>
                                                <xsl:value-of select="''"/>
                                            </gmd:URL>
                                        </gmd:linkage>
                                    </gmd:CI_OnlineResource>
                                </srv:connectPoint>
                            </srv:SV_OperationMetadata>
                        </srv:containsOperations>-->
                        
                        <!-- GETFEATURE -->
                        <srv:containsOperations>
                            <srv:SV_OperationMetadata>
                                <srv:operationName>
                                    <gco:CharacterString>GetFeature</gco:CharacterString>
                                </srv:operationName>
                                <srv:DCP>
                                    <!-- this codelist is also unknown -->
                                    <srv:DCPList codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#DCPList" codeListValue="HTTPGet"></srv:DCPList>
                                </srv:DCP>
                                
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Service</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Version</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Request</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Typename</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Maxfeatures</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Optional</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                
                                <!-- service link -->
                                <srv:connectPoint>
                                    <gmd:CI_OnlineResource>
                                        <gmd:linkage>
                                            <gmd:URL>
                                                <xsl:value-of select="$service-link"/>
                                            </gmd:URL>
                                        </gmd:linkage>
                                    </gmd:CI_OnlineResource>
                                </srv:connectPoint>
                            </srv:SV_OperationMetadata>
                        </srv:containsOperations>
                    </xsl:if>
                    
                    <xsl:if test="fn:lower-case($service-type)='wcs'">
                        <!-- DESCRIBECOVERAGE -->
                        <srv:containsOperations>
                            <srv:SV_OperationMetadata>
                                <srv:operationName>
                                    <gco:CharacterString>DescribeCoverage</gco:CharacterString>
                                </srv:operationName>
                                <srv:DCP>
                                    <!-- this codelist is also unknown -->
                                    <srv:DCPList codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#DCPList" codeListValue="HTTPGet"></srv:DCPList>
                                </srv:DCP>
                                
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Service</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Version</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Request</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Identifier</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                
                                <!-- service link -->
                                <srv:connectPoint>
                                    <gmd:CI_OnlineResource>
                                        <gmd:linkage>
                                            <gmd:URL>
                                                <xsl:value-of select="$service-link"/>
                                            </gmd:URL>
                                        </gmd:linkage>
                                    </gmd:CI_OnlineResource>
                                </srv:connectPoint>
                            </srv:SV_OperationMetadata>
                        </srv:containsOperations>
                        
                        <!-- GETCOVERAGE -->
                        <srv:containsOperations>
                            <srv:SV_OperationMetadata>
                                <srv:operationName>
                                    <gco:CharacterString>GetCoverage</gco:CharacterString>
                                </srv:operationName>
                                <srv:DCP>
                                    <!-- this codelist is also unknown -->
                                    <srv:DCPList codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#DCPList" codeListValue="HTTPGet"></srv:DCPList>
                                </srv:DCP>
                                
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Service</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Version</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>Request</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>COVERAGE</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>BBOX</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>FORMAT</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Mandatory</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>GRIDBASECRS</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Optional</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>GRIDCRS</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Optional</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>GRIDORIGIN</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Optional</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>GRIDOFFSETS</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Optional</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                <srv:parameters>
                                    <srv:SV_Parameter>
                                        <srv:name>
                                            <gco:aName>
                                                <gco:CharacterString>RANGESUBSET</gco:CharacterString>
                                            </gco:aName>
                                            <gco:attributeType>
                                                <gco:TypeName>
                                                    <gco:aName>
                                                        <gco:CharacterString>String</gco:CharacterString>
                                                    </gco:aName>
                                                </gco:TypeName>
                                            </gco:attributeType>
                                        </srv:name>
                                        <srv:direction>
                                            <srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
                                        </srv:direction>
                                        <srv:optionality>
                                            <gco:CharacterString>Optional</gco:CharacterString>
                                        </srv:optionality>
                                        <srv:repeatability>
                                            <gco:Boolean>false</gco:Boolean>
                                        </srv:repeatability>
                                        <srv:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>String</gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </srv:valueType>
                                    </srv:SV_Parameter>
                                </srv:parameters>
                                
                                <!-- service link -->
                                <srv:connectPoint>
                                    <gmd:CI_OnlineResource>
                                        <gmd:linkage>
                                            <gmd:URL>
                                                <xsl:value-of select="$service-link"/>
                                            </gmd:URL>
                                        </gmd:linkage>
                                    </gmd:CI_OnlineResource>
                                </srv:connectPoint>
                            </srv:SV_OperationMetadata>
                        </srv:containsOperations>
                    </xsl:if>
                    
                </srv:SV_ServiceIdentification>
            </gmd:identificationInfo>
            
        </gmd:MD_Metadata>
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
    <xsl:template name="generate-dateElement">
        <!--    must have date and time (so take care of it before calling)
            
            timestamp = yyyy-mm-dd | yyyy-mm-ddThh:mm:ss.sss+zz:zz | unknown | present
        -->
        <xsl:param name="datestring" select="()"></xsl:param>
        <xsl:param name="timestring" select="()"></xsl:param>
        <xsl:param name="tag-type"></xsl:param>
        
        <xsl:variable name="timestamp">
            <xsl:call-template name="format-datetime">
                <xsl:with-param name="datestring" select="$datestring"></xsl:with-param>
                <xsl:with-param name="timestring" select="$timestring"></xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        
        
        <xsl:choose>
            <xsl:when test="$timestamp = 'present' or $timestamp = 'unknown'">
                <xsl:choose>
                    <xsl:when test="$tag-type='date'">
                        <gmd:date gco:nilReason="unknown"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <gmd:dateTime gco:nilReason="unknown"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when> 
            <xsl:when test="not($timestamp = 'present' or $timestamp = 'unknown') and $tag-type='date'">
                <gmd:date>
                    <gco:Date><xsl:value-of select="$timestamp"></xsl:value-of></gco:Date>
                </gmd:date>
            </xsl:when>
            <xsl:when test="not($timestamp = 'present' or $timestamp = 'unknown') and $tag-type='datestamp'">
                <gco:Date><xsl:value-of select="$timestamp"></xsl:value-of></gco:Date>
            </xsl:when>
            <xsl:when test="not($timestamp = 'present' or $timestamp = 'unknown') and $tag-type='datetimestamp'">
                <gco:DateTime><xsl:value-of select="$timestamp"></xsl:value-of></gco:DateTime>
            </xsl:when>
            <xsl:otherwise>
                <gmd:dateTime>
                    <gco:DateTime><xsl:value-of select="$timestamp"></xsl:value-of></gco:DateTime>
                </gmd:dateTime>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    <xsl:template name="format-datetime">
        <xsl:param name="datestring" select="()"></xsl:param>
        <xsl:param name="timestring" select="()"></xsl:param>
        
        <xsl:variable name="date">
            <xsl:choose>
                <xsl:when test="not(fn:contains(fn:lower-case($datestring), 'unknown')) and not(fn:contains(fn:lower-case($datestring), 'unpublished')) and not(fn:contains(fn:lower-case($datestring), 'present'))">
                    <!-- convert to a yyyy-mm-dd string -->
                    <xsl:variable name="yr">
                        <xsl:value-of select="fn:substring($datestring, 1, 4)"/>
                    </xsl:variable>
                    <xsl:variable name="mn">
                        <xsl:choose>
                            <xsl:when test="fn:count(fn:tokenize($datestring, '-')) > 1">
                                <xsl:value-of select="fn:string(fn:tokenize($datestring, '-')[2])"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'01'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="dy">
                        <xsl:choose>
                            <xsl:when test="fn:count(fn:tokenize($datestring, '-')) > 2">
                                <xsl:value-of select="fn:string(fn:tokenize($datestring, '-')[3])"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'01'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:value-of select="$yr[text() != ''] | $mn[text() != ''] | $dy[text() != '']" separator="-"></xsl:value-of>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="fn:lower-case($datestring)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!--    just generate the datetime text, whatever it happens to be    -->
        <xsl:variable name="output-string">
            <xsl:choose>
                <xsl:when test="$date = 'present'">
                    <xsl:value-of select="'present'"></xsl:value-of>
                </xsl:when>
                <xsl:when test="($date and not($timestring)) or ($date and (contains(fn:lower-case($timestring), 'unknown') or contains(fn:lower-case($timestring), 'unpublished')))">
                    <xsl:value-of select="$date"/>
                </xsl:when>
                <xsl:when test="$date and $timestring and ($date != 'unknown' or contains($date, 'unpublished')) and ($date != 'unknown' or contains($date, 'unpublished'))">
                    <xsl:value-of select="fn:concat($date, 'T', $timestring)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'unknown'"></xsl:value-of>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:value-of select="$output-string"></xsl:value-of>
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
                            <gmd:country>
                                <gco:CharacterString><xsl:value-of select="address/country"></xsl:value-of></gco:CharacterString>
                            </gmd:country>
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