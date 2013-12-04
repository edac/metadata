<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0"
    xmlns:eml="eml://ecoinformatics.org/eml-2.1.1" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xsi:schemaLocation="eml://ecoinformatics.org/eml-2.1.1 eml.xsd">
    
    <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8"></xsl:output>
    
    <xsl:variable name="all-contacts" select="/metadata/contacts"></xsl:variable>
    <xsl:variable name="all-citations" select="/metadata/citations"></xsl:variable>
    
    <xsl:template match="/metadata">
        <eml:eml>
            <xsl:attribute name="packageId" select="'UNKNOWN'"></xsl:attribute>
            
            <xsl:variable name="identity-ptcontac-id" select="identification/contact[@role='point-contact']/@ref"/>
            <xsl:variable name="identity-contact" select="$all-contacts/contact[@id=$identity-ptcontac-id]"/>
            
            <xsl:variable name="identity-citation-id" select="identification/citation[@role='identify']/@ref"/>
            <xsl:variable name="identity-citation" select="$all-citations/citation[@id=$identity-citation-id]"/>
            
            <xsl:variable name="metadata-contact-id" select="metadata/contact/@ref"/>
            <xsl:variable name="metadata-contact" select="$all-contacts/contact[@id=$metadata-contact-id]"></xsl:variable>
            <dataset>
                <title>
                    <xsl:value-of select="identification/title"/>
                </title>
                
                <creator>
                    <xsl:apply-templates select="$identity-contact"></xsl:apply-templates>
                </creator> 
                
                <pubDate>
                    <xsl:value-of select="$identity-citation/publication/pubdate/@date"></xsl:value-of>
                </pubDate>
                
                <abstract>
                    <para>
                        <xsl:value-of select="identification/abstract"/>
                    </para> 
                </abstract> 
                <xsl:for-each select="identification/themes/theme">
                    <keywordSet>
                        <xsl:for-each select="term">
                            <keyword><xsl:value-of select="."/></keyword>
                        </xsl:for-each>
                         
                        <keywordThesaurus>
                            <xsl:value-of select="@thesaurus"/>
                        </keywordThesaurus>
                    </keywordSet> 
                </xsl:for-each>
                
                <intellectualRights>
                        <para>No statement of intellectual rights provided</para> 
                </intellectualRights> 
                
                <xsl:if test="distribution">
                    <distribution>
                        <xsl:for-each select="distribution/distributor/downloads/download/link">
                            <online> 
                                <url><xsl:value-of select="."/></url>
                            </online> 
                        </xsl:for-each>
                    </distribution> 
                </xsl:if>
                
                <coverage>          
                    <geographicCoverage> 
                        <geographicDescription>
                            <xsl:value-of select="spatial/indspref"/>
                        </geographicDescription>
                                    
                        <boundingCoordinates> 
                            <westBoundingCoordinate>
                                <xsl:value-of select="spatial/west"/>
                            </westBoundingCoordinate> 
                            <eastBoundingCoordinate>
                                <xsl:value-of select="spatial/east"/>
                            </eastBoundingCoordinate> 
                            <northBoundingCoordinate>
                                <xsl:value-of select="spatial/north"/>
                            </northBoundingCoordinate> 
                            <southBoundingCoordinate>
                                <xsl:value-of select="spatial/south"/>
                            </southBoundingCoordinate>
                                    
                        </boundingCoordinates> 
                    </geographicCoverage> 
                    <temporalCoverage id="{generate-id(identification/time)}">
                        <xsl:choose>
                            <xsl:when test="identification/time/range">
                                <rangeOfDates> 
                                    <beginDate>
                                        <calendarDate>
                                            <xsl:value-of select="identification/time/range/start/@date"/>
                                        </calendarDate> 
                                    </beginDate> 
                                    <endDate>
                                        <calendarDate>
                                            <xsl:value-of select="identification/time/range/end/@date"/>
                                        </calendarDate> 
                                    </endDate>
                                </rangeOfDates> 
                            </xsl:when>
                        </xsl:choose>         
                    </temporalCoverage>
                            
                </coverage> 
                <contact>
                    <xsl:apply-templates select="$metadata-contact"></xsl:apply-templates>                 
                    
                </contact> 
                
                <publisher>
                    <organizationName>
                        <xsl:value-of select="$metadata-contact/organization/name"/>
                    </organizationName> 
                </publisher>
            </dataset>
        </eml:eml>
    </xsl:template>
    
    <xsl:template match="contact">
        <individualName> 
            <givenName>No given name for contact provided</givenName> 
            <surName>No surname for contact provided</surName>
            
        </individualName> 
        <organizationName>
            <xsl:value-of select="organization/name"/>
        </organizationName> 
        <address>
            <xsl:for-each select="address/addr">
                <deliveryPoint>
                    <xsl:value-of select="."/>
                </deliveryPoint> 
            </xsl:for-each>
            
            <city>
                <xsl:value-of select="address/city"/>
            </city> 
            <administrativeArea>
                <xsl:value-of select="address/state"/>
            </administrativeArea> 
            <postalCode>
                <xsl:value-of select="address/postal"/>
            </postalCode> 
            <country>
                <xsl:value-of select="address/country"/>
            </country>
        </address> 
        <phone>
            <xsl:value-of select="voice"/>
        </phone> 
        <electronicMailAddress>
            <xsl:value-of select="email"/>
        </electronicMailAddress>
        
    </xsl:template>
    
</xsl:stylesheet>