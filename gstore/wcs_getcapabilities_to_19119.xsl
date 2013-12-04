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
    
    <xsl:import href="remove-namespaces.xsl"/>
    <xsl:output method="xml" encoding="ISO-8859-1" indent="yes"/>
    
    <!-- WCS GetCapabilities to ISO 19119 
        
        THIS IS NOT GENERAL PURPOSE (and it assumes just the one layer)
    
    NOTE: all of the wxs xml is slightly different as far as namespaces goes    
    -->
    
    <xsl:param name="app" select="'RGIS'"/>
    <xsl:param name="identifier" select="''"/>
    
    <xsl:variable name="cleaned">
        <xsl:call-template name="remove"/>
    </xsl:variable>
    
    <xsl:template match="/">
        <gmd:MD_Metadata>
            <xsl:attribute name="xsi:schemaLocation" select="'http://www.isotc211.org/2005/gmi http://www.ngdc.noaa.gov/metadata/published/xsd/schema.xsd'"/>
            
            <gmd:fileIdentifier>
                <gco:CharacterString>
                    <xsl:value-of select="fn:concat(fn:upper-case($app), '::', $identifier, '::ISO-19119:WCS')"/>
                </gco:CharacterString>
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
            <gmd:contact>
                <gmd:CI_ResponsibleParty>
                    
                    <xsl:if test="$cleaned/Capabilities/ServiceProvider/ProviderName">
                        <gmd:organisationName>
                            <gco:CharacterString>
                                <xsl:value-of select="$cleaned/Capabilities/ServiceProvider/ProviderName"/>
                            </gco:CharacterString>
                        </gmd:organisationName>
                    </xsl:if>
                    <xsl:if test="$cleaned/Capabilities/ServiceProvider/ServiceContact/IndividualName">
                        <gmd:positionName>
                            <gco:CharacterString>
                                <xsl:value-of select="$cleaned/Capabilities/ServiceProvider/ServiceContact/IndividualName"/>
                            </gco:CharacterString>
                        </gmd:positionName>
                    </xsl:if>
                    <gmd:contactInfo>
                        <gmd:CI_Contact>
                            <xsl:if test="$cleaned/Capabilities/ServiceProvider/ServiceContact/ContactInfo/Phone/Voice or $cleaned/Capabilities/ServiceProvider/ServiceContact/ContactInfo/Phone/Facsimile">
                                <gmd:phone>
                                    <gmd:CI_Telephone>
                                        <xsl:if test="$cleaned/Capabilities/ServiceProvider/ServiceContact/ContactInfo/Phone/Voice">
                                            <gmd:voice>
                                                <gco:CharacterString><xsl:value-of select="$cleaned/Capabilities/ServiceProvider/ServiceContact/ContactInfo/Phone/Voice"/></gco:CharacterString>
                                            </gmd:voice>
                                        </xsl:if>
                                        <xsl:if test="$cleaned/Capabilities/ServiceProvider/ServiceContact/ContactInfo/Phone/Facsimile">
                                            <gmd:facsimile>
                                                <gco:CharacterString><xsl:value-of select="$cleaned/Capabilities/ServiceProvider/ServiceContact/ContactInfo/Phone/Facsimile"/></gco:CharacterString>
                                            </gmd:facsimile>
                                        </xsl:if>
                                    </gmd:CI_Telephone>
                                </gmd:phone>
                            </xsl:if>
                            <gmd:address>
                                <gmd:CI_Address>
                                    <xsl:for-each select="$cleaned/Capabilities/ServiceProvider/ServiceContact/ContactInfo/Address/DeliveryPoint">
                                        <gmd:deliveryPoint>
                                            <gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
                                        </gmd:deliveryPoint>
                                    </xsl:for-each>
                                    <gmd:city>
                                        <gco:CharacterString><xsl:value-of select="$cleaned/Capabilities/ServiceProvider/ServiceContact/ContactInfo/Address/City"/></gco:CharacterString>
                                    </gmd:city>
                                    <gmd:administrativeArea>
                                        <gco:CharacterString><xsl:value-of select="$cleaned/Capabilities/ServiceProvider/ServiceContact/ContactInfo/Address/AdministrativeArea"/></gco:CharacterString>
                                    </gmd:administrativeArea>
                                    <gmd:postalCode>
                                        <gco:CharacterString><xsl:value-of select="$cleaned/Capabilities/ServiceProvider/ServiceContact/ContactInfo/Address/PostalCode"/></gco:CharacterString>
                                    </gmd:postalCode>
                                    <gmd:country>
                                        <gco:CharacterString><xsl:value-of select="$cleaned/Capabilities/ServiceProvider/ServiceContact/ContactInfo/Address/Country"/></gco:CharacterString>
                                    </gmd:country>
                                    <xsl:if test="$cleaned/Capabilities/ServiceProvider/ServiceContact/ContactInfo/Address/ElectronicMailAddress">
                                        <gmd:electronicMailAddress>
                                            <gco:CharacterString><xsl:value-of select="$cleaned/Capabilities/ServiceProvider/ServiceContact/ContactInfo/Address/ElectronicMailAddress"/></gco:CharacterString>
                                        </gmd:electronicMailAddress>
                                    </xsl:if>
                                </gmd:CI_Address>
                            </gmd:address>
                        </gmd:CI_Contact>              
                    </gmd:contactInfo>
                    <gmd:role>
                        <gmd:CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                            codeListValue="publisher">publisher</gmd:CI_RoleCode>
                    </gmd:role>
                </gmd:CI_ResponsibleParty>
            </gmd:contact>
            
            <!--<gmd:dateStamp>
                <xsl:call-template name="generate-dateElement">
                    <xsl:with-param name="datestring" select="metadata/pubdate/@date"></xsl:with-param>
                    <xsl:with-param name="timestring" select="metadata/pubdate/@time"></xsl:with-param>
                    <xsl:with-param name="tag-type" select="if (metadata/pubdate/@time) then 'datetimestamp' else 'datestamp'"></xsl:with-param>
                </xsl:call-template>
                </gmd:dateStamp>-->
            
            <gmd:dateStamp/>
            
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
                                    <xsl:value-of select="$cleaned/Capabilities/ServiceIdentification/Title"/>
                                </gco:CharacterString>
                            </gmd:title>
                            
                            <gmd:date gco:nilReason="unknown"/>
                        </gmd:CI_Citation>
                    </gmd:citation>
                    
                    <gmd:abstract>
                        <gco:CharacterString><xsl:value-of select="$cleaned/Capabilities/ServiceIdentification/Abstract"/></gco:CharacterString>
                    </gmd:abstract>
                    
                    <gmd:pointOfContact>
                        <gmd:CI_ResponsibleParty>
                            <xsl:if test="$cleaned/Capabilities/ServiceProvider/ProviderName">
                                <gmd:organisationName>
                                    <gco:CharacterString>
                                        <xsl:value-of select="$cleaned/Capabilities/ServiceProvider/ProviderName"/>
                                    </gco:CharacterString>
                                </gmd:organisationName>
                            </xsl:if>
                            <xsl:if test="$cleaned/Capabilities/ServiceProvider/ServiceContact/IndividualName">
                                <gmd:positionName>
                                    <gco:CharacterString>
                                        <xsl:value-of select="$cleaned/Capabilities/ServiceProvider/ServiceContact/IndividualName"/>
                                    </gco:CharacterString>
                                </gmd:positionName>
                            </xsl:if>
                            <gmd:contactInfo>
                                <gmd:CI_Contact>
                                    <xsl:if test="$cleaned/Capabilities/ServiceProvider/ServiceContact/ContactInfo/Phone/Voice or $cleaned/Capabilities/ServiceProvider/ServiceContact/ContactInfo/Phone/Facsimile">
                                        <gmd:phone>
                                            <gmd:CI_Telephone>
                                                <xsl:if test="$cleaned/Capabilities/ServiceProvider/ServiceContact/ContactInfo/Phone/Voice">
                                                    <gmd:voice>
                                                        <gco:CharacterString><xsl:value-of select="$cleaned/Capabilities/ServiceProvider/ServiceContact/ContactInfo/Phone/Voice"/></gco:CharacterString>
                                                    </gmd:voice>
                                                </xsl:if>
                                                <xsl:if test="$cleaned/Capabilities/ServiceProvider/ServiceContact/ContactInfo/Phone/Facsimile">
                                                    <gmd:facsimile>
                                                        <gco:CharacterString><xsl:value-of select="$cleaned/Capabilities/ServiceProvider/ServiceContact/ContactInfo/Phone/Facsimile"/></gco:CharacterString>
                                                    </gmd:facsimile>
                                                </xsl:if>
                                            </gmd:CI_Telephone>
                                        </gmd:phone>
                                    </xsl:if>
                                    <gmd:address>
                                        <gmd:CI_Address>
                                            <xsl:for-each select="$cleaned/Capabilities/ServiceProvider/ServiceContact/ContactInfo/Address/DeliveryPoint">
                                                <gmd:deliveryPoint>
                                                    <gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
                                                </gmd:deliveryPoint>
                                            </xsl:for-each>
                                            <gmd:city>
                                                <gco:CharacterString><xsl:value-of select="$cleaned/Capabilities/ServiceProvider/ServiceContact/ContactInfo/Address/City"/></gco:CharacterString>
                                            </gmd:city>
                                            <gmd:administrativeArea>
                                                <gco:CharacterString><xsl:value-of select="$cleaned/Capabilities/ServiceProvider/ServiceContact/ContactInfo/Address/AdministrativeArea"/></gco:CharacterString>
                                            </gmd:administrativeArea>
                                            <gmd:postalCode>
                                                <gco:CharacterString><xsl:value-of select="$cleaned/Capabilities/ServiceProvider/ServiceContact/ContactInfo/Address/PostalCode"/></gco:CharacterString>
                                            </gmd:postalCode>
                                            <gmd:country>
                                                <gco:CharacterString><xsl:value-of select="$cleaned/Capabilities/ServiceProvider/ServiceContact/ContactInfo/Address/Country"/></gco:CharacterString>
                                            </gmd:country>
                                            <xsl:if test="$cleaned/Capabilities/ServiceProvider/ServiceContact/ContactInfo/Address/ElectronicMailAddress">
                                                <gmd:electronicMailAddress>
                                                    <gco:CharacterString><xsl:value-of select="$cleaned/Capabilities/ServiceProvider/ServiceContact/ContactInfo/Address/ElectronicMailAddress"/></gco:CharacterString>
                                                </gmd:electronicMailAddress>
                                            </xsl:if>
                                        </gmd:CI_Address>
                                    </gmd:address>
                                </gmd:CI_Contact>              
                            </gmd:contactInfo>
                            <gmd:role>
                                <gmd:CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                                    codeListValue="'pointOfContact'"></gmd:CI_RoleCode>
                            </gmd:role>
                        </gmd:CI_ResponsibleParty>
                    </gmd:pointOfContact>
                    
                    <xsl:for-each select="$cleaned/Capabilities/ServiceIdentification/Keywords">
                        <gmd:descriptiveKeywords>
                            <gmd:MD_Keywords>
                                <xsl:for-each select="Keyword">
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
                                            <gco:CharacterString><xsl:value-of select="'Unknown'"></xsl:value-of></gco:CharacterString>
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
                            <xsl:value-of select="fn:translate($cleaned/Capabilities/ServiceIdentification/ServiceType, ' ', ':')"/>
                        </gco:LocalName>
                    </srv:serviceType>
                    <srv:serviceTypeVersion>
                        <gco:CharacterString>
                            <xsl:value-of select="$cleaned/Capabilities/ServiceIdentification/ServiceTypeVersion"/>
                        </gco:CharacterString>
                    </srv:serviceTypeVersion>
                    
                    <srv:extent>
                        <gmd:EX_Extent id="boundingExtent">
                            <gmd:geographicElement>
                                <gmd:EX_GeographicBoundingBox id="geographicExtent">
                                    <gmd:westBoundLongitude>
                                        <gco:Decimal><xsl:value-of select="fn:substring-before($cleaned/Capabilities/Contents/CoverageSummary/WGS84BoundingBox/LowerCorner, ' ')"/></gco:Decimal>
                                    </gmd:westBoundLongitude>
                                    <gmd:eastBoundLongitude>
                                        <gco:Decimal><xsl:value-of select="fn:substring-before($cleaned/Capabilities/Contents/CoverageSummary/WGS84BoundingBox/UpperCorner, ' ')"></xsl:value-of></gco:Decimal>
                                    </gmd:eastBoundLongitude>
                                    <gmd:southBoundLatitude>
                                        <gco:Decimal><xsl:value-of select="fn:substring-after($cleaned/Capabilities/Contents/CoverageSummary/WGS84BoundingBox/LowerCorner, ' ')"></xsl:value-of></gco:Decimal>
                                    </gmd:southBoundLatitude>
                                    <gmd:northBoundLatitude>
                                        <gco:Decimal><xsl:value-of select="fn:substring-after($cleaned/Capabilities/Contents/CoverageSummary/WGS84BoundingBox/UpperCorner, ' ')"></xsl:value-of></gco:Decimal>
                                    </gmd:northBoundLatitude>
                                </gmd:EX_GeographicBoundingBox>
                            </gmd:geographicElement>
                        </gmd:EX_Extent>
                    </srv:extent>
                    
                    <srv:couplingType>
                        <!-- this codelist doesn't seem to exist  -->
                        <srv:SV_CouplingType codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#SV_CouplingType" codeListValue="mixed"></srv:SV_CouplingType>
                    </srv:couplingType>
                    
                    <xsl:if test="$cleaned/Capabilities/OperationsMetadata/Operation[@name='GetCapabilities']">
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
                                                <xsl:value-of select="$cleaned/Capabilities/OperationsMetadata/Operation[@name='GetCapabilities']/DCP/HTTP/Get/@href"/>
                                            </gmd:URL>
                                        </gmd:linkage>
                                    </gmd:CI_OnlineResource>
                                </srv:connectPoint>
                            </srv:SV_OperationMetadata>
                        </srv:containsOperations>
                    </xsl:if>
                    
                    <xsl:if test="$cleaned/Capabilities/OperationsMetadata/Operation[@name='DescribeCoverage']">
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
                                                <xsl:value-of select="$cleaned/Capabilities/OperationsMetadata/Operation[@name='DescribeCoverage']/DCP/HTTP/Get/@href"/>
                                            </gmd:URL>
                                        </gmd:linkage>
                                    </gmd:CI_OnlineResource>
                                </srv:connectPoint>
                            </srv:SV_OperationMetadata>
                        </srv:containsOperations>
                    </xsl:if>
                    
                    <xsl:if test="$cleaned/Capabilities/OperationsMetadata/Operation[@name='GetCoverage']">
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
                                                <xsl:value-of select="$cleaned/Capabilities/OperationsMetadata/Operation[@name='GetCoverage']/DCP/HTTP/Get/@href"/>
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
</xsl:stylesheet>