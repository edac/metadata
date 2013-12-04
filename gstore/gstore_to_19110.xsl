<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:gss="http://www.isotc211.org/2005/gss"
    xmlns="http://www.isotc211.org/2005/gfc"
    xmlns:gts="http://www.isotc211.org/2005/gts"
    xmlns:gml="http://www.opengis.net/gml/3.2"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:gco="http://www.isotc211.org/2005/gco"
    xmlns:gmd="http://www.isotc211.org/2005/gmd"
    xmlns:gfc="http://www.isotc211.org/2005/gfc"
    xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xmlns:gsr="http://www.isotc211.org/2005/gsr"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    >

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:param name="dataset-identifier" select="fn:tokenize(fn:substring-before(fn:base-uri(.), '.xml'), '/')[last()]"></xsl:param>
    
    <xsl:template match="/metadata">
        <gfc:FC_FeatureCatalogue>
            <xsl:attribute name="id" select="'FC001'"></xsl:attribute>
            <xsl:attribute name="uuid" select="$dataset-identifier"></xsl:attribute>
            <xsl:attribute name="xsi:schemaLocation" select="'http://www.isotc211.org/2005/gfc http://www.isotc211.org/2005/gfc/gfc.xsd'"></xsl:attribute>
            
            <gmx:name>
                <gco:CharacterString><xsl:value-of select="fn:concat('Feature Catalogue for ', identification/title)"/></gco:CharacterString>
            </gmx:name>
            <gmx:scope gco:nilReason="unknown"/>
            <gmx:versionNumber gco:nilReason="unknown"/>
            <gmx:versionDate gco:nilReason="unknown"/>
            <gmx:language>
                <gco:CharacterString>eng; US</gco:CharacterString>
            </gmx:language>
            <gmx:characterSet>
                <gmd:MD_CharacterSetCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_CharacterSetCode"
                    codeListValue="utf8"/>
            </gmx:characterSet>
           
            <!-- the metadata contact -->
            <xsl:variable name="metadata-contact-ref" select="metadata/contact[@role='point-contact']/@ref"/>
            <xsl:variable name="metadata-contact">
                <xsl:copy-of select="contacts/contact[@id = $metadata-contact-ref]"/>
            </xsl:variable>
            <gfc:producer>
                <gmd:CI_ResponsibleParty>
                    <gmd:organisationName>
                        <gco:CharacterString><xsl:value-of select="$metadata-contact/contact/organisation/name"/></gco:CharacterString>
                    </gmd:organisationName>
                    <gmd:positionName>
                        <gco:CharacterString><xsl:value-of select="$metadata-contact/contact/position"/></gco:CharacterString>
                    </gmd:positionName>
                    <gmd:contactInfo>
                        <gmd:CI_Contact>
                            <gmd:phone>
                                <gmd:CI_Telephone>
                                    <gmd:voice>
                                        <gco:CharacterString><xsl:value-of select="$metadata-contact/contact/voice"/></gco:CharacterString>
                                    </gmd:voice>
                                    <gmd:facsimile>
                                        <gco:CharacterString><xsl:value-of select="$metadata-contact/contact/fax"/></gco:CharacterString>
                                    </gmd:facsimile>
                                </gmd:CI_Telephone>
                            </gmd:phone>
                            <gmd:address>
                                <gmd:CI_Address>
                                    <xsl:for-each select="$metadata-contact/contact/address/addr">
                                        <gmd:deliveryPoint>
                                            <gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
                                        </gmd:deliveryPoint>
                                    </xsl:for-each>
                                    <gmd:city>
                                        <gco:CharacterString><xsl:value-of select="$metadata-contact/contact/address/city"/></gco:CharacterString>
                                    </gmd:city>
                                    <gmd:administrativeArea>
                                        <gco:CharacterString><xsl:value-of select="$metadata-contact/contact/address/state"/></gco:CharacterString>
                                    </gmd:administrativeArea>
                                    <gmd:postalCode>
                                        <gco:CharacterString><xsl:value-of select="$metadata-contact/contact/address/postal"/></gco:CharacterString>
                                    </gmd:postalCode>
                                    <xsl:if test="$metadata-contact/contact/address/country">
                                        <gmd:country>
                                            <gco:CharacterString><xsl:value-of select="$metadata-contact/contact/address/country"/></gco:CharacterString>
                                        </gmd:country>
                                    </xsl:if>
                                    <xsl:if test="$metadata-contact/contact/email">
                                        <gmd:electronicMailAddress>
                                            <gco:CharacterString><xsl:value-of select="$metadata-contact/contact/email"/></gco:CharacterString>
                                        </gmd:electronicMailAddress>
                                    </xsl:if>
                                </gmd:CI_Address>
                            </gmd:address>
                            <xsl:if test="$metadata-contact/contact/hours">
                                <gmd:hoursOfService>
                                    <gco:CharacterString><xsl:value-of select="$metadata-contact/contact/hours"/></gco:CharacterString>
                                </gmd:hoursOfService>
                            </xsl:if>
                        </gmd:CI_Contact>
                    </gmd:contactInfo>
                    <gmd:role>
                        <gmd:CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                            codeListValue="resourceProvider"/>
                    </gmd:role>
                </gmd:CI_ResponsibleParty>
            </gfc:producer>
            <gfc:featureType>
                <gfc:FC_FeatureType>
                    <gfc:typeName>
                        <gco:LocalName><xsl:value-of select="attributes/entity/label"/></gco:LocalName>
                    </gfc:typeName>
                    <gfc:definition>
                        <gco:CharacterString><xsl:value-of select="attributes/entity/description"/></gco:CharacterString>
                    </gfc:definition>
                    <gfc:isAbstract>
                        <gco:Boolean>false</gco:Boolean>
                    </gfc:isAbstract>
                    <gfc:featureCatalogue uuidref="FC001"/>
                    
                    <xsl:for-each select="attributes/attr">
                        <gfc:carrierOfCharacteristics>
                            <gfc:FC_FeatureAttribute>
                                
                                <xsl:if test="range">
                                    <gfc:constrainedBy>
                                        <gfc:FC_Constraint>
                                            <gfc:description>
                                                <xsl:variable name="max">
                                                    <xsl:choose>
                                                        <xsl:when test="range/max">
                                                            <xsl:value-of select="fn:concat('Range Domain Max: ', range/max)"/>
                                                        </xsl:when>
                                                    </xsl:choose>
                                                </xsl:variable>
                                                <xsl:variable name="min">
                                                    <xsl:choose>
                                                        <xsl:when test="range/min">
                                                            <xsl:value-of select="fn:concat('Range Domain Min: ', range/min)"/>
                                                        </xsl:when>
                                                    </xsl:choose>
                                                </xsl:variable>
                                                <!-- TODO: no attribute resolution yet -->
                                                <gco:CharacterString>
                                                    <xsl:value-of select="$max[text() != ''] | $min[text() != '']" separator=" | "/>
                                                </gco:CharacterString>
                                            </gfc:description>
                                        </gfc:FC_Constraint>
                                    </gfc:constrainedBy>
                                </xsl:if>
                                
                                <gfc:memberName>
                                    <gco:LocalName><xsl:value-of select="label"/></gco:LocalName>
                                </gfc:memberName>
                                <gfc:definition>
                                    <gco:CharacterString><xsl:value-of select="definition"/></gco:CharacterString>
                                </gfc:definition>
                                <gfc:cardinality gco:nilReason="unknown"/>
                                
                                <gfc:definitionReference>
                                    <gfc:FC_DefinitionReference>
                                        <gfc:definitionSource>
                                            <gfc:FC_DefinitionSource>
                                                <gfc:source>
                                                    <gmd:CI_Citation>
                                                        <gmd:title gco:nilReason="inapplicable"/>
                                                        <gmd:date gco:nilReason="unknown"/>
                                                        <gmd:citedResponsibleParty>
                                                            <gmd:CI_ResponsibleParty>
                                                                <gmd:organisationName>
                                                                    <gco:CharacterString><xsl:value-of select="source"/></gco:CharacterString>
                                                                </gmd:organisationName>
                                                                <gmd:role>
                                                                    <gmd:CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                                                                        codeListValue="resourceProvider"/>
                                                                </gmd:role>
                                                            </gmd:CI_ResponsibleParty>
                                                        </gmd:citedResponsibleParty>
                                                    </gmd:CI_Citation>
                                                </gfc:source>
                                            </gfc:FC_DefinitionSource>
                                        </gfc:definitionSource>
                                    </gfc:FC_DefinitionReference>
                                </gfc:definitionReference>
                                
                                <xsl:choose>
                                    <xsl:when test="range">
                                        <gfc:valueMeasurementUnit>
                                            <gml:BaseUnit gml:id="{generate-id(.)}">
                                                <gml:identifier codeSpace="{range/units}"></gml:identifier>
                                                <gml:unitsSystem nilReason="unknown"/>
                                            </gml:BaseUnit>
                                        </gfc:valueMeasurementUnit>
                                    </xsl:when>
                                    <xsl:when test="unrepresented">
                                        <gfc:valueType>
                                            <gco:TypeName>
                                                <gco:aName>
                                                    <gco:CharacterString>
                                                        <xsl:value-of select="unrepresented/description"/>
                                                    </gco:CharacterString>
                                                </gco:aName>
                                            </gco:TypeName>
                                        </gfc:valueType>
                                    </xsl:when>
                                    <xsl:when test="enumerated">
                                        <xsl:for-each select="enumerated/value">
                                            <gfc:listedValue>
                                                <gfc:FC_ListedValue>
                                                    <gfc:label>
                                                        <gco:CharacterString><xsl:value-of select="enum"/></gco:CharacterString>
                                                    </gfc:label>
                                                    <gfc:definition>
                                                        <gco:CharacterString><xsl:value-of select="description"/></gco:CharacterString>
                                                    </gfc:definition>
                                                    <gfc:definitionReference>
                                                        <gfc:FC_DefinitionReference>
                                                            <gfc:definitionSource>
                                                                <gfc:FC_DefinitionSource>
                                                                    <gfc:source>
                                                                        <gmd:CI_Citation>
                                                                            <gmd:title gco:nilReason="inapplicable"/>
                                                                            <gmd:date gco:nilReason="unknown"/>
                                                                            <gmd:citedResponsibleParty>
                                                                                <gmd:CI_ResponsibleParty>
                                                                                    <gmd:organisationName>
                                                                                        <gco:CharacterString><xsl:value-of select="source"/></gco:CharacterString>
                                                                                    </gmd:organisationName>
                                                                                    <gmd:role>
                                                                                        <gmd:CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                                                                                            codeListValue="resourceProvider"/>
                                                                                    </gmd:role>
                                                                                </gmd:CI_ResponsibleParty>
                                                                            </gmd:citedResponsibleParty>
                                                                        </gmd:CI_Citation>
                                                                    </gfc:source>
                                                                </gfc:FC_DefinitionSource>
                                                            </gfc:definitionSource>
                                                        </gfc:FC_DefinitionReference>
                                                    </gfc:definitionReference>
                                                </gfc:FC_ListedValue>
                                            </gfc:listedValue>
                                        </xsl:for-each>
                                    </xsl:when>
                                    <xsl:when test="codeset">
                                        <gfc:listedValue>
                                            <gfc:FC_ListedValue>
                                                <gfc:label>
                                                    <gco:CharacterString>
                                                        <xsl:value-of select="codeset/name"></xsl:value-of>
                                                    </gco:CharacterString>
                                                </gfc:label>
                                                <gfc:definitionReference>
                                                    <gfc:FC_DefinitionReference>
                                                        <gfc:definitionSource>
                                                            <gfc:FC_DefinitionSource>
                                                                <gfc:source>
                                                                    <gmd:CI_Citation>
                                                                        <gmd:title gco:nilReason="inapplicable"/>
                                                                        <gmd:date gco:nilReason="unknown"/>
                                                                        <gmd:citedResponsibleParty>
                                                                            <gmd:CI_ResponsibleParty>
                                                                                <gmd:organisationName>
                                                                                    <gco:CharacterString><xsl:value-of select="codeset/source"/></gco:CharacterString>
                                                                                </gmd:organisationName>
                                                                                <gmd:role>
                                                                                    <gmd:CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                                                                                        codeListValue="resourceProvider"/>
                                                                                </gmd:role>
                                                                            </gmd:CI_ResponsibleParty>
                                                                        </gmd:citedResponsibleParty>
                                                                    </gmd:CI_Citation>
                                                                </gfc:source>
                                                            </gfc:FC_DefinitionSource>
                                                        </gfc:definitionSource>
                                                    </gfc:FC_DefinitionReference>
                                                </gfc:definitionReference>
                                            </gfc:FC_ListedValue>
                                        </gfc:listedValue>
                                    </xsl:when>
                                </xsl:choose>
                            </gfc:FC_FeatureAttribute>
                        </gfc:carrierOfCharacteristics>
                    </xsl:for-each>
                </gfc:FC_FeatureType>
            </gfc:featureType>
            <xsl:if test="attributes/entity/source">
                <gfc:definitionSource>
                    <gfc:FC_DefinitionSource>
                        <gfc:source>
                            <gmd:CI_Citation>
                                <gmd:title gco:nilReason="inapplicable"/>
                                <gmd:date gco:nilReason="unknown"/>
                                <gmd:citedResponsibleParty>
                                    <gmd:CI_ResponsibleParty>
                                        <gmd:organisationName>
                                            <gco:CharacterString><xsl:value-of select="attributes/entity/source"/></gco:CharacterString>
                                        </gmd:organisationName>
                                        <gmd:role>
                                            <gmd:CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                                                codeListValue="resourceProvider"/>
                                        </gmd:role>
                                    </gmd:CI_ResponsibleParty>
                                </gmd:citedResponsibleParty>
                            </gmd:CI_Citation>
                        </gfc:source>
                    </gfc:FC_DefinitionSource>
                </gfc:definitionSource>
            </xsl:if>
        </gfc:FC_FeatureCatalogue>
    </xsl:template>
</xsl:stylesheet>